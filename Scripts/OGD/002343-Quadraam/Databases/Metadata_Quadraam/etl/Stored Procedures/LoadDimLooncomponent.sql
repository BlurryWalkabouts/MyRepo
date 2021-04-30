CREATE PROCEDURE [etl].[LoadDimLooncomponent]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Looncomponent

SET XACT_ABORT ON
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Looncomponent ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Looncomponent (LooncomponentKey, Looncomponent, Grondslag)
VALUES
	(-1, '', '[Onbekend]')
SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Looncomponent OFF

INSERT INTO
	[$(DWH_Quadraam)].Dim.Looncomponent
	(
	Looncomponent
	, Grondslag
	)
SELECT DISTINCT
	Looncomponent = lc.Looncomponent
	, Grondslag = lc.Grondslag
FROM
	[$(Staging_Quadraam)].[Afas].[DWH_HR_Werkgeverskosten] lc

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
	SET IDENTITY_INSERT [$(DWH_Quadraam)].Dim.Looncomponent OFF
END CATCH
RETURN 0
END