CREATE PROCEDURE [setup].[LoadSharePointForecast]
AS
BEGIN

SET NOCOUNT ON

TRUNCATE TABLE [$(Staging_Quadraam)].SharePoint.Forecast

INSERT INTO
	[$(Staging_Quadraam)].SharePoint.Forecast
	(
	BudgetCode
	, Jaar
	, Maand
	, GrootboekRekeningCode
	, KostenplaatsCode
	, MutatieBedrag
	, Toelichting
	)
SELECT
	BudgetCode = p.value('BudgetCode[1]','varchar(50)')
	, Jaar = p.value('Jaar[1]','int')
	, Maand = p.value('Maand[1]','int')
	, GrootboekRekeningCode = p.value('GrootboekRekeningCode[1]','int')
	, KostenplaatsCode = p.value('KostenplaatsCode[1]','int')
	, MutatieBedrag = CAST(COALESCE(REPLACE(p.value('MutatieBedrag[1]','nvarchar(15)'),',','.'),0) AS decimal(14,4))
	, Toelichting = p.value('Toelichting[1]','nvarchar(max)')
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY XMLData.nodes('/Mutatie') R(p)
WHERE 1=1
	AND j.DataSource = 'SharePoint'
	AND j.ContentType = 'Data'
	AND j.Connector LIKE 'Forecast'

/* Laad de metadata via views in de temporal table */

-- Declareer een tabelvariabele om alle acties in op te slaan; dit wordt een lijst met de steekwoorden 'UPDATE', 'INSERT' en 'DELETE'
DECLARE @actions table (Operation varchar(6))

INSERT INTO
	@actions
SELECT
	Operation
FROM
(
MERGE INTO
	[$(Archive_Quadraam)].SharePoint.Forecast WITH (SERIALIZABLE) t -- Doeltabel
USING
	[$(Staging_Quadraam)].SharePoint.Forecast s -- Brontabel
ON 1=1
	AND s.BudgetCode = t.BudgetCode
	AND s.Jaar = t.Jaar
	AND s.Maand = t.Maand
	AND s.KostenplaatsCode = t.KostenplaatsCode
	AND s.GrootboekRekeningCode = t.GrootboekRekeningCode
WHEN MATCHED
	AND EXISTS ( -- Extra predicaat om identieke rijen eruit te filteren
		SELECT s.BudgetCode, s.Jaar, s.Maand, s.KostenplaatsCode, s.GrootboekRekeningCode, s.MutatieBedrag, s.Toelichting
		EXCEPT
		SELECT t.BudgetCode, t.Jaar, t.Maand, t.KostenplaatsCode, t.GrootboekRekeningCode, t.MutatieBedrag, t.Toelichting
	) THEN
	UPDATE
	SET
		t.MutatieBedrag = t.MutatieBedrag + s.MutatieBedrag
		, t.Toelichting = s.Toelichting
WHEN NOT MATCHED THEN
	INSERT
	(
		BudgetCode
		, Jaar
		, Maand
		, KostenplaatsCode
		, GrootboekRekeningCode
		, MutatieBedrag
		, Toelichting
	)
	VALUES
	(
		s.BudgetCode
		, s.Jaar
		, s.Maand
		, s.KostenplaatsCode
		, s.GrootboekRekeningCode
		, s.MutatieBedrag
		, s.Toelichting
	)
--WHEN NOT MATCHED BY SOURCE AND t.DataSource LIKE @patDataSource AND t.Connector LIKE @patConnector THEN
--	DELETE
OUTPUT
	$action AS Operation
--	, COALESCE(inserted.Connector, deleted.Connector) AS Connector
--	, COALESCE(inserted.ID, deleted.ID) AS ID
) sub

/* Pivot de acties om het aantal gewijzigde rijen weer te geven */

;WITH PivotData AS
(
SELECT
	LoadDate = SYSUTCDATETIME() -- Groeperen
	, Operation -- Spreiden
	, Amount = 1 -- Aggregeren
FROM
	@actions
UNION ALL
SELECT -- Voeg een dummy rij toe; deze zorgt ervoor dat als er helemaal niets veranderd is, er toch een resultaat (0-0-0) wordt weergegeven
	LoadDate = SYSUTCDATETIME()
	, Operation = NULL
	, Amount = 0
)

-- Uiteindelijk zal het resultaat van deze tabel moeten worden opgeslagen
INSERT INTO
	[log].TableChanges
	(
	TABLE_CATALOG
	, TABLE_SCHEMA
	, TABLE_NAME
	, PatDataSource
	, PatConnector
	, LoadDate
	, Updated
	, Inserted
	, Deleted
	)
OUTPUT
	inserted.LoadDate
	, inserted.Updated
	, inserted.Inserted
	, inserted.Deleted
SELECT
	TABLE_CATALOG = 'Archive_Quadraam'
	, TABLE_SCHEMA = 'SharePoint'
	, TABLE_NAME = 'Forecast'
	, PatDataSource = ''
	, PatConnector = ''
	, LoadDate
	, Updated = COALESCE([UPDATE], 0)
	, Inserted = COALESCE([INSERT], 0)
	, Deleted = COALESCE([DELETE], 0)
FROM
	PivotData
	PIVOT (COUNT(Amount) FOR Operation IN ([UPDATE],[INSERT],[DELETE])) P

DELETE FROM [$(DWH_Quadraam)].Fact.Mutatie WHERE [Source] = 'X'

INSERT INTO
	[$(DWH_Quadraam)].Fact.Mutatie
	(
	BoekDatumKey
	, FactuurDatumKey
	, DagboekKey
	, GrootboekKey
	, KostenplaatsKey
	, KostendragerKey
	, ScenarioKey
	, TransactieTypeKey
	, FactuurKey
	, MutatieOmschrijving
	, BegrotingOpmerking
	, MutatieBedrag
	, Boekstuknummer
	, [Source]
	)
SELECT
	BoekDatumKey = COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, FactuurDatumKey = COALESCE(CAST(m.MaandKey AS VARCHAR(8))+'01', -1)
	, DagboekKey = -1
	, GrootboekKey = COALESCE(gb.GrootboekKey, -1)
	, KostenplaatsKey = COALESCE(kp.KostenplaatsKey, -1)
	, KostendragerKey = -1
	, ScenarioKey = -1
	, TransactieTypeKey = 2 -- Forecast
	, FactuurKey = -1
	, MutatieOmschrijving = COALESCE(f.Toelichting, '')
	, BegrotingOpmerking = '' 
	, MutatieBedrag = COALESCE(f.MutatieBedrag, 0)
	, Boekstuknummer = ''
	, [Source] = 'X'
FROM
	[$(Archive_Quadraam)].SharePoint.Forecast f
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Grootboek gb ON f.GrootboekRekeningCode = gb.GrootboekRekeningCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Kostenplaats kp ON f.KostenplaatsCode = kp.KostenplaatsCode
	LEFT OUTER JOIN [$(DWH_Quadraam)].Dim.Maand m ON m.JaarNum = f.Jaar AND m.MaandNum = f.Maand

END