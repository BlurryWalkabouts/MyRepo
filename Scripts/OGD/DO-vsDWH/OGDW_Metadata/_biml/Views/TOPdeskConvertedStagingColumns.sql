CREATE VIEW [setup].[TOPdeskConvertedStagingColumns]
AS

WITH cte AS
(
SELECT
	C.build
	, C.TABLE_SCHEMA
	, C.TABLE_NAME
	, C.COLUMN_NAME
	, source_column_fulltype = C.DATA_TYPE 
		+ CASE WHEN C.DATA_TYPE LIKE '%varchar' THEN '(' + CASE WHEN (C.CHARACTER_MAXIMUM_LENGTH = -1) THEN 'MAX)' ELSE CAST(C.CHARACTER_MAXIMUM_LENGTH AS varchar(max)) + ')' END ELSE '' END
		+ CASE WHEN C.DATA_TYPE IN ('decimal','numeric') THEN '(' + CAST(C.NUMERIC_PRECISION AS varchar(max)) + ', ' + CAST(C.NUMERIC_PRECISION_RADIX AS varchar(max)) + ')' ELSE '' END
	, column_create_sql = '[' + C.COLUMN_NAME + '] ' + C.DATA_TYPE 
		+ CASE WHEN C.DATA_TYPE LIKE '%varchar' THEN '(' + CASE WHEN (C.CHARACTER_MAXIMUM_LENGTH = -1) THEN 'MAX)' ELSE CAST(C.CHARACTER_MAXIMUM_LENGTH AS varchar(max)) + ')' END ELSE '' END
		+ CASE WHEN C.DATA_TYPE IN ('decimal','numeric') THEN '(' + CAST(C.NUMERIC_PRECISION AS varchar(max)) + ', ' + CAST(C.NUMERIC_PRECISION_RADIX AS varchar(max)) + ')' ELSE '' END
		+ CASE WHEN C.IS_NULLABLE = 'YES' THEN ' NULL' ELSE ' NOT NULL' END
		+ ', '
	, C.ORDINAL_POSITION
	-- Target column (type hiervan wijkt af voor uniqueidentifier-kolommen)
	, target_table_schema = T.TABLE_SCHEMA
	, target_column_fulltype = T.DATA_TYPE
		+ CASE WHEN T.DATA_TYPE LIKE '%varchar' THEN '(' + CASE WHEN (T.CHARACTER_MAXIMUM_LENGTH = -1) THEN 'MAX)' ELSE CAST(T.CHARACTER_MAXIMUM_LENGTH AS varchar(max)) + ')' END ELSE '' END
		+ CASE WHEN T.DATA_TYPE IN ('decimal','numeric') THEN '(' + CAST(T.NUMERIC_PRECISION AS varchar(max)) + ', ' + CAST(T.NUMERIC_PRECISION_RADIX AS varchar(max)) + ')' ELSE '' END
FROM
	[$(MDS)].mdm.TOPdesk_Columns C
	INNER JOIN [$(OGDW_Staging)].INFORMATION_SCHEMA.COLUMNS T ON 1=1
		AND C.TABLE_NAME = T.TABLE_NAME
		AND C.COLUMN_NAME = T.COLUMN_NAME
		-- Schema in OGDW_Staging moet matchen met TD-build:
		AND T.TABLE_SCHEMA LIKE ('%' + LEFT(C.build,5) + '%')
WHERE 1=1
	AND import = 1
)

SELECT
	build
	, TABLE_SCHEMA
	, TABLE_NAME
	, COLUMN_NAME
	, source_column_fulltype
	, column_create_sql
	, ORDINAL_POSITION
	, target_table_schema
	, target_column_fulltype
	, converted_column_name = CASE
			WHEN source_column_fulltype = target_column_fulltype THEN COLUMN_NAME
			ELSE 'CONVERT(' + target_column_fulltype + ', [' + COLUMN_NAME + ']) AS ' + COLUMN_NAME
		END
FROM
	cte