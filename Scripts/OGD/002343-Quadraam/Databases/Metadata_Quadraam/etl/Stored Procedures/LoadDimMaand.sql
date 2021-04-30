CREATE PROCEDURE [etl].[LoadDimMaand]
AS
BEGIN

-- Get StartTime
DECLARE @StartTime DATETIME2 = GETDATE()

BEGIN TRY
BEGIN TRANSACTION

TRUNCATE TABLE [$(DWH_Quadraam)].Dim.Maand

SET XACT_ABORT ON
INSERT INTO
	[$(DWH_Quadraam)].Dim.Maand (MaandKey, JaarNum, MaandNum, MaandNaam, MaandNaamKort, MaandJaarNum, MaandJaarNaam)
VALUES
	(-1, 1900, 1, '', '', '1900-01', '')

INSERT INTO
	[$(DWH_Quadraam)].Dim.Maand
	(
	MaandKey
	, JaarNum
	, MaandNum
	, MaandNaam
	, MaandNaamKort
	, MaandJaarNum
	, MaandJaarNaam
	)
SELECT DISTINCT
	MaandKey = CAST(JaarNum AS nvarchar) + CASE WHEN MaandNum > 9 THEN CAST(MaandNum AS nvarchar) ELSE '0' + CAST(MaandNum AS nvarchar) END
	, JaarNum = JaarNum
	, MaandNum = MaandNum
	, MaandNaam = MaandNaam
	, MaandNaamKort = MaandNaamKort
	, MaandJaarNum = MaandJaarNum
	, MaandJaarNaam	= MaandJaarNaam	
FROM
	[$(DWH_Quadraam)].Dim.Datum

WHERE JaarNum > 1900

;EXEC [log].[Log] @@PROCID, @StartTime

SET XACT_ABORT OFF
COMMIT TRANSACTION

END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION
	EXEC [log].[Log] @@PROCID, @StartTime
	SET XACT_ABORT OFF
END CATCH
RETURN 0
END