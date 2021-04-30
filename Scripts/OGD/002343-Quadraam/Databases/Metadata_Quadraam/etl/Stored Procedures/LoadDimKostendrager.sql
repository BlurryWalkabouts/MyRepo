CREATE PROCEDURE [etl].[LoadDimKostendrager]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Kostendrager

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostendrager ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Kostendrager (KostendragerKey, KostendragerCode, KostendragerNaam)
VALUES
	(-1, '', '[Onbekend]')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostendrager OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Kostendrager
	(
	KostendragerCode
	, KostendragerNaam
	)
SELECT
	KostendragerCode = COALESCE(kd2.Nummer, kd1.kstdrcode)
	, KostendragerNaam = COALESCE(kd2.Omschrijving, kd1.oms25_0, '')
FROM
	[$(Exact)].dbo.kstdr kd1
	FULL OUTER JOIN [$(Staging_Quadraam)].Afas.DWH_FIN_Kostendragers kd2 ON kd1.kstdrcode = kd2.Nummer AND kd1.oms25_0 <> '*****'

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Kostendrager OFF
END CATCH
RETURN 0
END