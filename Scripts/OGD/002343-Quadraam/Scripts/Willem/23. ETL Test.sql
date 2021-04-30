SELECT
	j.*
	, k.*
FROM
	[Staging_Quadraam].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn) k
WHERE 1=1
--	AND j.DataSource = 'DUO'
	AND j.ContentType = 'Metadata'

BEGIN TRANSACTION
EXEC setup.LoadMetadata @patDataSource = '%', @patConnector = '%', @debug = 1
EXEC setup.LoadData @patDataSource = '%', @patConnector = '%', @debug = 1
SELECT * FROM setup.vwMetadata('%','%')
SELECT * FROM setup.vwMetadataAfas
SELECT * FROM setup.vwMetadataDUO ORDER BY TABLE_NAME, ORDINAL_POSITION
SELECT * FROM setup.vwMetadataTables
SELECT * FROM setup.vwMetadataColumns
SELECT * FROM [log].TableChanges
--TRUNCATE TABLE [log].TableChanges
SELECT *, ValidFrom, ValidTo FROM setup.Metadata ORDER BY DataSource, Connector
COMMIT TRANSACTION
ROLLBACK TRANSACTION

EXEC shared.DisableVersioning 'Metadata_Quadraam','setup','Metadata'
DELETE FROM setup.Metadata WHERE DataSource = 'DUO'
EXEC shared.EnableVersioning 'Metadata_Quadraam','setup','Metadata'
/*
EXEC setup.CreateStagingTables @patDataSource = 'DUO', @patConnector = '%', @debug = 1
EXEC setup.CreateStagingTables @patDataSource = 'DUO', @patConnector = 'alle_vestigingen_vo', @debug = 1
EXEC setup.CreateStagingTables @patDataSource = 'DUO', @patConnector = 'leerlingen_vo_per_vestiging_en_bestuur_vavo_apart', @debug = 1
EXEC setup.CreateStagingTables @patDataSource = 'DUO', @patConnector = 'leerlingen_vo_per_vestiging_naar_onderwijstype', @debug = 1
*/
EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = '%', @debug = 1
EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = 'examenkandidaten_en_geslaagden', @debug = 1
EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = 'alle_vestigingen_vo', @debug = 1
EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = 'leerlingen_vo_per_vestiging_en_bestuur_vavo_apart', @debug = 1
EXEC setup.LoadDataIntoStaging @patDataSource = 'DUO', @patConnector = 'leerlingen_vo_per_vestiging_naar_onderwijstype', @debug = 1

SELECT
	'SELECT TABLE_NAME = ''' + TABLE_NAME + ''', Aantal = COUNT(*) FROM ' + TABLE_CATALOG + '.' + TABLE_SCHEMA + '.' + TABLE_NAME + ' UNION'
FROM
	Staging_Quadraam.INFORMATION_SCHEMA.TABLES
WHERE 1=1
	AND TABLE_SCHEMA = 'DUO'
ORDER BY
	TABLE_NAME