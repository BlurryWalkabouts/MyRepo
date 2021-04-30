CREATE VIEW [setup].[DBImportColumnDefintion]
AS

WITH columns_filtered AS
(
SELECT DISTINCT SourceColumn = TD_SourceColumn, TableName = TD_SourceTableName FROM setup.DWColumnDefinition WHERE Import = 1
UNION
SELECT DISTINCT SourceColumn = TD_JoinKey, TableName = TD_SourceTableName FROM setup.DWColumnDefinition WHERE Import = 1
UNION
SELECT DISTINCT SourceColumn = TD_JoinForeignKey, TableName = TD_JoinForeignTable FROM setup.DWColumnDefinition WHERE Import = 1
) 

, target_columns AS
(
SELECT
	TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, CHARACTER_MAXIMUM_LENGTH
	, NUMERIC_PRECISION
	, NUMERIC_SCALE
	, IS_NULLABLE = CASE WHEN IS_NULLABLE = 'YES' THEN 1 ELSE 0 END
FROM
	[$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS
)

SELECT
	TableName = cf.TableName
	, SourceColumn = cf.SourceColumn
	, TargetDataType = tc.DATA_TYPE
	, TargetCharMaxLen = tc.CHARACTER_MAXIMUM_LENGTH
	, TargetNumPrec = tc.NUMERIC_PRECISION
	, TargetNumScale = tc.NUMERIC_SCALE
	, TargetIsNullable = tc.IS_NULLABLE
FROM
	columns_filtered cf
	INNER JOIN target_columns tc ON cf.TableName = tc.TABLE_NAME AND cf.SourceColumn = tc.COLUMN_NAME