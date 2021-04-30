/*
SELECT * 
FROM sys.views 
WHERE OBJECTPROPERTY(object_id, 'IsSchemaBound') = 1

exec dbo.usp_ViewRemoveSchemaBinding 'vDCMDeploymentSettings'
exec dbo.usp_ViewRemoveSchemaBinding 'vDCMDeploymentCIs'
exec dbo.usp_ViewRemoveSchemaBinding 'vDCMDeploymentRules'
exec dbo.usp_ViewRemoveSchemaBinding 'vRBAC_TypeWideOperations'
exec dbo.usp_ViewRemoveSchemaBinding 'vAppDeploymentTargetingInfoBase'
*/

--insert into [ogd-source-analysis.database.windows.net_ogd-configmgr].[ogd-configmgr].sccm_ext.Add_Remove_Programs_64_DATA_DD
--select * from sccm_ext.Add_Remove_Programs_64_DATA_DD

--select * from information_schema.columns where Data_type = 'timestamp' and 

declare @table_name sysname
declare @table_schema sysname
declare @column_name sysname
declare @is_nullable sysname
declare @sql nvarchar(max)
declare @pk sysname

-- Iterate over all tables needed for replication
declare T cursor  for
	select DISTINCT C.table_name, C.table_schema, C.COLUMN_NAME, C.IS_NULLABLE
	from information_schema.columns C
	inner join information_schema.tables T ON (T.table_schema = C.table_schema and T.table_name = C.table_name AND T.table_type = 'base table')
	where DATA_TYPE = 'timestamp' and C.TABLE_NAME not like 'syncobj_%' and C.TABLE_SCHEMA = 'SCCM_Ext'
	order by C.TABLE_NAME
open T

fetch next from T into @table_name, @table_schema, @column_name, @is_nullable
while @@FETCH_STATUS = 0
begin
	print 'Processing: ' + quotename(@table_schema) + '.' + quotename(@table_name)
	-- Rename the timestamp column
	print '|- Renaming timestamp column'
	set @sql = 'exec sp_rename ''' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + '.' + QUOTENAME(@column_name) + ''', ''' + @column_name + '_renamed' + ''', ''COLUMN'''
	exec(@sql)

	print '|- Creating replacement column'
	-- Creating the varbinary replacement
	set @sql = 'ALTER TABLE ' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + char(10) + 
			   char(9) + ' ADD ' + QUOTENAME(@column_name) + ' varbinary(50) ' +
			   (case when @is_nullable = 'NO' THEN 'NOT ' ELSE '' END) + 'NULL DEFAULT(0)'
	--print @sql
	exec(@sql)

	-- Datapump
	print '|- Pumping data'
	set @sql = 'UPDATE ' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + char(10) +
			   char(9) + 'SET ' + quotename(@column_name) + ' = ' + QUOTENAME(@column_name + '_renamed')
	exec(@sql)

	-- Check if column is a primary key

	print '|- PK Check...'
	IF (
		SELECT COUNT(*)
		FROM INFORMATION_SCHEMA.KEY_COLUMN_USAGE
		WHERE OBJECTPROPERTY(OBJECT_ID(CONSTRAINT_SCHEMA + '.' + QUOTENAME(CONSTRAINT_NAME)), 'IsPrimaryKey') = 1
		AND TABLE_NAME = @table_name AND TABLE_SCHEMA = @table_schema AND COLUMN_NAME = @column_name + '_renamed'
	) = 1 BEGIN
		print '|-- PK Detected'
		-- Gathering primary key name. Assuming it's a single column
		set @pk = (select name FROM sys.key_constraints WHERE type = 'PK' AND parent_object_id = OBJECT_ID(N'' + @table_schema + '.' + @table_name + ''));  

		-- Removing old PK
		print '|-- Removing pk' + @pk
		set @sql = 'ALTER TABLE ' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + char(10) + 
				   char(9) + ' DROP CONSTRAINT ' + quotename(@pk)
		exec(@sql)

		-- New PK
		print '|-- Adding pk' + @pk
		set @sql = 'ALTER TABLE ' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + char(10) + 
				   char(9) + ' ADD CONSTRAINT ' + quotename(@pk) + ' PRIMARY KEY(' + quotename(@column_name) +')'
		exec(@sql)
	END

	-- Remove old column
	print '|- Removing timestamp column'
	set @sql = 'ALTER TABLE ' + quotename(@table_schema) + '.' + QUOTENAME(@table_name) + char(10) + 
			   char(9) + ' DROP COLUMN ' + QUOTENAME(@column_name + '_renamed')
	exec(@sql)

	print char(10)
fetch next from T into @table_name, @table_schema, @column_name, @is_nullable
end

close T
deallocate T