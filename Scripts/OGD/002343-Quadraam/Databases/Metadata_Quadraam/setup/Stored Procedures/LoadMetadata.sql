CREATE PROCEDURE [setup].[LoadMetadataSub]
(
	@patDataSource varchar(64)
	, @patConnector varchar(64)
)
AS
BEGIN

SET NOCOUNT ON

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
	setup.Metadata WITH (SERIALIZABLE) t -- Doeltabel
USING
	setup.vwMetadata(@patDataSource,@patConnector) s -- Brontabel
ON 1=1
	AND s.DataSource = t.DataSource
	AND s.Connector = t.Connector
	AND s.OriginalColumnName = t.OriginalColumnName
WHEN MATCHED
	AND EXISTS ( -- Extra predicaat om identieke rijen eruit te filteren
		SELECT s.DataSource, s.Connector, s.OriginalColumnName, s.TABLE_NAME, s.COLUMN_NAME, s.DATA_TYPE, s.ORDINAL_POSITION
		EXCEPT
		SELECT t.DataSource, t.Connector, t.OriginalColumnName, t.TABLE_NAME, t.COLUMN_NAME, t.DATA_TYPE, t.ORDINAL_POSITION
	) THEN
	UPDATE
	SET
		t.TABLE_NAME = s.TABLE_NAME
		, t.COLUMN_NAME = s.COLUMN_NAME
		, t.DATA_TYPE = s.DATA_TYPE
		, t.ORDINAL_POSITION = s.ORDINAL_POSITION
WHEN NOT MATCHED THEN
	INSERT
	(
		DataSource
		, Connector
		, OriginalColumnName
		, TABLE_NAME
		, COLUMN_NAME
		, DATA_TYPE
		, ORDINAL_POSITION
	)
	VALUES
	(
		s.DataSource
		, s.Connector
		, s.OriginalColumnName
		, s.TABLE_NAME
		, s.COLUMN_NAME
		, s.DATA_TYPE
		, s.ORDINAL_POSITION
	)
WHEN NOT MATCHED BY SOURCE AND t.DataSource LIKE @patDataSource AND t.Connector LIKE @patConnector THEN
	DELETE
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
	TABLE_CATALOG = 'Metadata_Quadraam'
	, TABLE_SCHEMA = 'setup'
	, TABLE_NAME = 'Metadata'
	, PatDataSource = @patDataSource
	, PatConnector = @patConnector
	, LoadDate
	, Updated = COALESCE([UPDATE], 0)
	, Inserted = COALESCE([INSERT], 0)
	, Deleted = COALESCE([DELETE], 0)
FROM
	PivotData
	PIVOT (COUNT(Amount) FOR Operation IN ([UPDATE],[INSERT],[DELETE])) P

END