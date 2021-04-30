CREATE PROCEDURE [etl].[LoadDimDagboek]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Dagboek

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dagboek ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Dagboek (DagboekKey, DagboekCode, DagboekNaam, DagboekType, Boekstuknummer)
VALUES
	(-1, '', '[Onbekend]', '', '')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dagboek OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Dagboek
	(
	DagboekCode
	, DagboekNaam
	, DagboekType
	, Boekstuknummer
	)
SELECT
	DagboekCode = COALESCE(db2.Dagboekcode, db1.dagbknr)
	, DagboekNaam = COALESCE(db2.Omschrijving, db1.oms25_0, '')
	, DagboekType = COALESCE(db2.[Type], db1.type_dgbk, '')
	, Boekstuknummer = NULL
FROM
	[$(Exact)].dbo.dagbk db1
	FULL OUTER JOIN [$(Staging_Quadraam)].Afas.DWH_FIN_Dagboeken db2 ON db1.dagbknr = db2.Dagboekcode

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF 
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Dagboek OFF
END CATCH
RETURN 0
END