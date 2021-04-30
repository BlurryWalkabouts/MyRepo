CREATE PROCEDURE [etl].[LoadDimScenario]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Scenario

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Scenario ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Scenario (ScenarioKey, ScenarioCode, ScenarioNaam, Boekjaar, Source)
VALUES
	(-1, '', '[Onbekend]', 1900, '')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Scenario OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Scenario
	(
	ScenarioCode
	, ScenarioNaam
	, Boekjaar
	, [Source]
	)
SELECT 
	ScenarioCode = bud_vers
	, ScenarioNaam = oms30_0
	, Boekjaar = bkjrcode_v
	, [Source] = 'E'
FROM
	[$(Exact)].dbo.bdgvrs b
	LEFT OUTER JOIN [$(Exact)].dbo.DDTests t1 ON b.vers_stat = t1.DatabaseChar AND t1.Tablename = 'bdgvrs' AND t1.FieldName = 'vers_stat'
	LEFT OUTER JOIN [$(Exact)].dbo.DDTests t2 ON b.planperiod = t2.DatabaseChar AND t2.Tablename = 'bdgvrs' AND t2.FieldName = 'planperiod'

UNION

SELECT DISTINCT
	ScenarioCode = Budgetscenario
	, ScenarioNaam = Naam
	, Boekjaar = Jaar
	, [Source] = 'A'
FROM
	[$(Staging_Quadraam)].Afas.DWH_FIN_Budget

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Scenario OFF
END CATCH
RETURN 0
END