DECLARE @sql nvarchar(max);
DECLARE @table_name sysname = 'absencereason'
DECLARE @table_schema sysname = 'dim'

SET @sql = 'SELECT ' + char(10) + char(9) + ' ' + (SELECT STUFF((SELECT char(10) + char(9) + ',' + CAST('[' + Column_Name + ']' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.table_schema = @table_schema and C.Table_name = @table_name and RIGHT(column_name, 3) != 'Key' and Column_Name != 'IsCurrent'
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 3, '')) + char(10)
SET @sql += 'FROM OPENJSON(@SerializedJson) ' + char(10) + 'WITH (';
SET @sql += (SELECT STUFF((SELECT ',' + char(10) + char(9) + CAST('[' + Column_Name + '] ' + '[' + DATA_TYPE + ']' + (CASE WHEN Character_Maximum_Length IS NOT NULL THEN '(' + (CASE CAST(Character_Maximum_Length AS NVARCHAR) WHEN -1 THEN 'MAX' ELSE CAST(Character_Maximum_Length AS NVARCHAR) END) + ')' ELSE (CASE WHEN DATA_TYPE IN ('bit', 'tinyint', 'bigint', 'int',
'smallint', 'uniqueidentifier', 'money', 'time', 'date') THEN '' WHEN DATA_Type IN ('datetime2') THEN '(' + CAST(datetime_precision AS NVARCHAR) + ')' ELSE '(' + CAST(NUMERIC_PRECISION AS NVARCHAR) + ',' + CAST(NUMERIC_SCALE AS NVARCHAR) + ')'  END) END) + (' ''$.' + Column_Name + '''') as nvarchar(max)) 
			FROM Information_schema.columns C
			WHERE C.Table_Schema = @table_schema AND C.Table_name = @table_name
			ORDER BY C.ORDINAL_POSITION 
			FOR XML PATH('')
		), 1, 1, ''))
SET @sql += char(10) + ')';

print @sql;
	
/*
MERGE Dim.OperatorGroup T
USING (
	-- Deserializing JSON object
	select * from openjson(@SerializedJson) WITH (
			[OperatorGroupGuid] [uniqueidentifier] '$.OperatorGroupGuid'
		,[OperatorGroup] [nvarchar](255) '$.OperatorGroup'
		,[ChangeDate] [datetime2](7) '$.ChangeDate'
	)) S
	ON (T.CustomerKey = @CustomerKey AND T.[OperatorGroupGuid] = S.[OperatorGroupGuid])
	WHEN MATCHED THEN UPDATE SET
		-- Update existing records
			T.[OperatorGroup] = S.[OperatorGroup],
			T.[ChangeDate] = S.[ChangeDate]

	WHEN NOT MATCHED  BY TARGET THEN INSERT
		([CustomerKey],[CustomerNumber],[OperatorGroupGuid],[OperatorGroup],[ChangeDate])
		VALUES
			(@CustomerKey,@CustomerNumber,[OperatorGroupGuid],[OperatorGroup],[ChangeDate])
	;
	*/