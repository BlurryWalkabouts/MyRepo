
DECLARE @TableName nvarchar(255);
DECLARE @TableSchema nvarchar(255);

DECLARE @ColumnName nvarchar(255);
DECLARE @ColumnType nvarchar(255);

DECLARE @sql nvarchar(max);

DECLARE resourceCursor CURSOR FOR   
SELECT [Table_Name], [Table_Schema] 
FROM INFORMATION_SCHEMA.Tables
WHERE Table_schema IN ('dim', 'fact') and Table_Name NOT IN ('Date')
order by table_name

OPEN resourceCursor  

FETCH NEXT FROM resourceCursor   
INTO @TableName, @TableSchema

WHILE @@FETCH_STATUS = 0  
BEGIN  
	PRINT ' '
	PRINT '--- Loading [Unknown] for: ' + @TableName + ' ---'

	-- Emptying table
	SET @sql  = CONCAT('TRUNCATE TABLE [', @tableSchema, '].[', @tableName, ']', char(10));
	-- Enabling Identity Insert
	SET @sql += CONCAT('SET IDENTITY_INSERT [', @tableSchema, '].[', @tableName, '] ON;', char(10));
	-- Insert statement
	SET @sql += CONCAT('INSERT INTO [', @tableSchema, '].[', @tableName, '](');
	-- Column List
	SET @sql += (SELECT STUFF((
				SELECT ',[' + Column_Name + ']'
			FROM Information_schema.columns C
			WHERE C.Table_Name = @TableName AND C.Table_Schema = @TableSchema AND Column_Name NOT IN (SELECT name FROM sys.computed_columns WHERE object_id = OBJECT_ID(@TableSchema + '.' + @TableName))
			ORDER BY C.ORDINAL_POSITION 
			FOR XML PATH('')
		), 1, 1, ''))
	SET @sql += ')'+char(10)
	-- Values defintion
	SET @sql += 'VALUES(';

	SET @sql += (SELECT STUFF((
				SELECT ',' + (
					CASE WHEN DATA_TYPE = 'bit' THEN '0'
							WHEN DATA_TYPE IN ('bigint', 'int', 'smallint') THEN '-1'
							WHEN DATA_TYPE = 'tinyint' THEN '0'
							WHEN DATA_TYPE = 'uniqueidentifier' THEN '''00000000-0000-0000-0000-000000000000'''
							WHEN DATA_TYPE IN ('money', 'numeric', 'decimal') THEN '0'
							WHEN DATA_TYPE = 'time' THEN '''00:00:00'''
							WHEN DATA_TYPE IN ('date', 'datetime2', 'datetime') THEN '''9999-12-31''' 
							WHEN DATA_TYPE IN ('nvarchar', 'varchar') THEN 
								CASE WHEN C.Character_Maximum_Length > 8 THEN '''[Unknown]''' ELSE '''?''' END
							WHEN DATA_TYPE IN ('nchar', 'char') THEN '''?'''
							ELSE 'NULL'
					END
				)
			FROM Information_schema.columns C
			WHERE C.Table_Name = @TableName AND C.Table_Schema = @TableSchema AND Column_Name NOT IN (SELECT name FROM sys.computed_columns WHERE object_id = OBJECT_ID(@TableSchema + '.' + @TableName))
			ORDER BY C.ORDINAL_POSITION 
			FOR XML PATH('')
		), 1, 1, ''))

	SET @sql += ');'+char(10)

	-- Disabling Identity Insert
	SET @sql += CONCAT('SET IDENTITY_INSERT [', @tableSchema, '].[', @tableName, '] OFF;', char(10));
	-- Reseeding, since it will still be upped.
	SET @sql += CONCAT('DBCC CHECKIDENT(''', @tableSchema, '.', @tableName, ''', RESEED, 1);', char(10));
	 
	print @sql
	exec(@sql)

	FETCH NEXT FROM resourceCursor   
	INTO @TableName, @tableSchema
END   
CLOSE resourceCursor;
DEALLOCATE resourceCursor;