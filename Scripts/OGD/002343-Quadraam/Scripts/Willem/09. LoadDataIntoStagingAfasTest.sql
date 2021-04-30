USE Metadata_Quadraam;
GO

--EXEC setup.LoadMetadataAfas
EXEC setup.CreateStagingTablesAfas
EXEC setup.LoadDataIntoStagingAfas --@pattern = 'DWH_HR_%'
EXEC etl.RunETL

SELECT * FROM Staging_Quadraam.Afas.DWH_FIN_Mutaties

DECLARE @dir nvarchar(64) = 'F:\JSON\'
DECLARE @debug bit = 1

EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Dimensies', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Dimensies_2', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Dimensies_3', @debug = @debug

EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Administraties', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_BTWcode', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Crediteuren', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Dagboeken', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Grootboek', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Kosten', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Kostendragers', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Kostenplaatsen', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Mutaties', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Periodes', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Projecten', @debug = @debug
EXEC setup.LoadDataIntoStagingAfasSub @dir = @dir, @table = 'DWH_FIN_Valuta', @debug = @debug

SELECT 'SELECT ''' + TABLE_NAME + ''', COUNT(*) FROM Staging_Quadraam.Afas.' + TABLE_NAME + ' UNION'
FROM Staging_Quadraam.INFORMATION_SCHEMA.TABLES ORDER BY TABLE_NAME