CREATE FUNCTION [monitoring].[CheckMissingColumns]
(
	@SourceDatabaseDWKey int
	, @AuditDWKey int
)
RETURNS TABLE
AS
RETURN

WITH source_trans AS
( 
SELECT
	DWStagingTableName
	, DWColumn
	, SourceColumn
FROM
	setup.vwSourceColumnTranslations
WHERE 1=1
	AND SourceDatabaseDWKey = @SourceDatabaseDWKey
) 

, default_trans AS
( 
SELECT
	FI_StagingTableName
	, DWColumn
	, FI_SourceColumn
FROM
	setup.vwDefaultColumnTranslations
)

, dwCols AS
( 
SELECT
	DWColumn
	, FI_StagingTableName
FROM
	setup.DWColumnDefinition
) 

-- Dit is de metadata van het excel-bestand, ingelezen door een script in het ssis-package
, metadata AS
(
SELECT
	MD_SourceColumn = Metadata.ColumnName
FROM
	FileImport.MetaData
	INNER JOIN [log].[Audit] a ON MetaData.AuditDWKey = a.AuditDWKey
WHERE 1=1
	AND a.AuditDWKey = @AuditDWKey
	AND a.SourceDatabaseKey = @SourceDatabaseDWKey
)

-- Complete lijst met DWColumn, SourceColumn, inclusief regels waarvoor geen SourceColumn bestaat
, all_trans AS
( 
SELECT
	DWStagingTableName
	, DWColumn
	, SourceColumn
FROM
	source_trans
UNION
SELECT
	FI_StagingTableName
	, DWColumn
	, FI_SourceColumn
FROM
	default_trans
WHERE 1=1
	AND NOT EXISTS (SELECT SourceColumn FROM source_trans WHERE source_trans.DWStagingTableName = default_trans.FI_StagingTableName AND source_trans.DWColumn = default_trans.DWColumn)
)

SELECT
	ExpectedColumns = LEFT(all_trans.SourceColumn,64) -- Afgekapt op 64 characters vanwege limitaties Microsoft.Jet.OleDB 
FROM
	all_trans
	LEFT OUTER JOIN dwCols ON all_trans.DWStagingTableName = dwCols.FI_StagingTableName AND all_trans.DWColumn = dwCols.DWColumn
WHERE 1=1
	AND all_trans.DWStagingTableName = (SELECT SourceFileType FROM setup.SourceDefinition WHERE Code = @SourceDatabaseDWKey)
	AND all_trans.SourceColumn IS NOT NULL
EXCEPT
SELECT
	MD_SourceColumn
FROM
	metadata