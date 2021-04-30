CREATE PROCEDURE [etl].[LoadDimTransactieType]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.TransactieType

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.TransactieType ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.TransactieType (TransactieTypeKey, TransactieTypeCode, TransactieTypeNaam)
VALUES
	(-1, '', '[Onbekend]')
	, (1, 'B', '[Begroting]')
	, (2, 'F', '[Forecast]')
	, (3, 'R', '[Realisatie]')

;EXEC [log].[Log] @@PROCID, @StartTime

SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.TransactieType OFF

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.TransactieType OFF
END CATCH
RETURN 0
END