declare @SQL nvarchar(max)
declare @table_name sysname
declare @table_schema sysname

-- Fetching all non-history tables
declare T cursor  for
	select DISTINCT table_name, table_schema
	from INFORMATION_SCHEMA.TABLES 
	where table_schema != 'history' AND Table_type = 'BASE TABLE'
	order by TABLE_SCHEMA, TABLE_NAME
open T

fetch next from T into @table_name, @table_schema
while @@FETCH_STATUS = 0
begin
	PRINT 'Adding System Period: ' + QUOTENAME(@table_schema) + '.' + QUOTENAME(@table_name) + ';'
	-- TRUNCATING ALL DATA IN ORIGINAL TABLE
	SET @SQL = 'ALTER TABLE ' + QUOTENAME(@table_schema) + '.' + QUOTENAME(@table_name) + ' ADD PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo]);'
	EXEC(@SQL)

	-- Fetching and inserting data. This might take a while
	PRINT 'Enabling versioning'
	SET @SQL  = 'ALTER TABLE ' + QUOTENAME(@table_schema) + '.' + QUOTENAME(@table_name) + ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.' + quotename(@table_name) + ', DATA_CONSISTENCY_CHECK = ON));'
	EXEC(@SQL)

	SET @SQL = ''

fetch next from T into @table_name, @table_schema
end

close T
deallocate T