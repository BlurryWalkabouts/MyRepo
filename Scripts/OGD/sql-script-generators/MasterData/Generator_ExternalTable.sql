DECLARE @schemaName nvarchar(255) = 'HumanResources'
DECLARE @sql nvarchar(max) = ''
declare @table_name sysname
declare @table_schema sysname
declare @column_name sysname

-- Iterate over all tables needed for to be built remotely
declare T cursor  for
	select DISTINCT table_name, table_schema
	from Information_schema.tables T
	WHERE T.TABLE_TYPE = 'VIEW' AND table_schema IN ('MasterData') and table_name NOT IN ('date', 'time')-- and table_name = 'customer'
	order by T.TABLE_NAME
open T

fetch next from T into @table_name, @table_schema
while @@FETCH_STATUS = 0
begin

	SET @sql = ''
	SET @sql += 'IF OBJECT_ID(''' + @schemaName + '.' + @table_name + ''') IS NOT NULL DROP EXTERNAL TABLE [' + @schemaName + '].[' + @table_name + ']' + char(10)
	SET @sql += 'GO' + char(10)
	SET @sql += 'CREATE EXTERNAL TABLE [' + @schemaName + '].[' + @table_name + ']' + char(10) + '('
	SET @sql += (SELECT STUFF((SELECT ',' + char(10) + char(9) + CAST('[' + Column_Name + '] ' + '[' + DATA_TYPE + ']' + (CASE WHEN Character_Maximum_Length IS NOT NULL THEN '(' + (CASE CAST(Character_Maximum_Length AS NVARCHAR) WHEN -1 THEN 'MAX' ELSE CAST(Character_Maximum_Length AS NVARCHAR) END) + ') ' ELSE (CASE WHEN DATA_TYPE IN ('bit', 'tinyint', 'bigint', 'int',
'smallint', 'uniqueidentifier', 'money', 'time', 'date','datetime') THEN '' WHEN DATA_Type IN ('datetime2') THEN '(' + CAST(datetime_precision AS NVARCHAR) + ') ' ELSE '(' + CAST(NUMERIC_PRECISION AS NVARCHAR) + ',' + CAST(NUMERIC_SCALE AS NVARCHAR) + ')'  END) END) + (CASE WHEN IS_NULLABLE = 'YES' THEN  'NULL' ELSE ' NOT NULL' END) as nvarchar(max)) 
			FROM Information_schema.columns C
			WHERE C.Table_Schema = @table_schema AND C.Table_name = @table_name
			ORDER BY C.ORDINAL_POSITION 
			FOR XML PATH('')
		), 1, 1, ''))
	SET @sql += char(10) + ')' + char(10) + 'WITH (DATA_SOURCE = [' + @schemaName + '], Schema_name=''' + @table_schema + ''', object_name=''' + @table_name + ''')' + char(10)

	PRINT @sql

fetch next from T into @table_name, @table_schema
end

close T
deallocate T
