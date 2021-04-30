DECLARE @schemaName nvarchar(255) = 'preload'
DECLARE @sql nvarchar(max) = ''
declare @table_name sysname
declare @table_schema sysname
declare @column_name sysname
declare @primarykey sysname

/*
-- This is only a temp solution! 
TO DO: Use code below to generate fk dependency checker
*/

/*
select 
	 s.name
    ,t.name as TableWithForeignKey
    ,fk.constraint_column_id as FK_PartNo
	,c.name as ForeignKeyColumn 
from 
    sys.foreign_key_columns as fk
inner join 
    sys.tables as t on fk.parent_object_id = t.object_id
inner join 
    sys.columns as c on fk.parent_object_id = c.object_id and fk.parent_column_id = c.column_id
inner join sys.schemas as s on (s.schema_id = t.schema_id)
order by 
    TableWithForeignKey, FK_PartNo
*/

declare T cursor  for
	select DISTINCT table_name, table_schema
	from Information_schema.tables T
	WHERE T.TABLE_TYPE = 'BASE TABLE' AND table_schema in ('dim', 'fact') and table_name NOT IN ('date', 'time') and table_name = 'operatorgroup'
	order by table_schema, T.TABLE_NAME
open T

fetch next from T into @table_name, @table_schema
while @@FETCH_STATUS = 0
begin

	SELECT @primaryKey = Col.Column_Name
	from 
		INFORMATION_SCHEMA.TABLE_CONSTRAINTS Tab, 
		INFORMATION_SCHEMA.CONSTRAINT_COLUMN_USAGE Col 
	WHERE 
    Col.Constraint_Name = Tab.Constraint_Name
    AND Col.Table_Name = Tab.Table_Name
    AND Constraint_Type = 'PRIMARY KEY'
    AND Col.Table_Name = @table_name
	AND Col.Table_Schema = @table_schema

	IF (SELECT COUNT(*) FROM Information_schema.columns where table_name = @table_name and table_schema = @table_schema and column_name = 'IsCurrent') > 0 BEGIN
		SET @sql = 'INSERT INTO [' + @table_schema + '].[' + @table_name + ']' + char(10)
		SET @sql += 'SELECT ' + (SELECT STUFF((SELECT ',' + CAST('[' + Column_Name + ']' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 1, '')) + ' FROM (' + char(10)
		SET @sql += char(9) + 'MERGE [' + @table_schema + '].[' + @table_name + '] T' + char(10)
		SET @sql += char(9) + 'USING [' + @schemaName + '].[' + @table_name + '] S'
		
		PRINT @sql

		SET @sql = ''

		IF (SELECT COUNT(*) FROM Information_schema.columns where table_name = @table_name and table_schema = @table_schema and column_name = 'ValidFrom') > 0 BEGIN
			SET @sql += char(9) + 'ON (T.[' + @primaryKey + '] = S.[' + @primaryKey + '])' + char(10) --AND T.[ValidFrom] = S.[ValidFrom] AND T.[ValidTo] = S.[ValidTo])' + char(10)
		END
		ELSE BEGIN
			SET @sql += char(9) + 'ON (T.[' + @primaryKey + '] = S.[' + @primaryKey + '])' + char(10)
		END

		SET @sql += char(9) + 'WHEN NOT MATCHED THEN' + char(10)
		SET @sql += char(9) + 'INSERT VALUES (' + (SELECT STUFF((SELECT ',S.' + CAST('[' + Column_Name + '] ' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 1, '')) + ')' + char(10)
	

		SET @sql += char(9) + 'WHEN MATCHED AND T.IsCurrent = 1 AND (' + char(10)
		SET @sql += char(9) + (SELECT STUFF((SELECT ' OR T.' + CAST('[' + Column_Name + '] != S.' + '[' + Column_Name + ']' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name AND C.column_name NOT IN ('ValidFrom', 'ValidTo', 'IsCurrent')
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 3, '')) + ') THEN' + char(10)
		SET @sql += char(9) + 'UPDATE SET T.ValidTo = ''' + CAST((SELECT convert(date,getutcdate()-1, 106)) AS NVARCHAR) + '''' + char(10)
		
		SET @sql += char(9) + 'OUTPUT $Action Action_Out, ' + (SELECT STUFF((SELECT ',S.' + CAST('[' + Column_Name + '] ' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name and C.column_name NOT IN ('IsCurrent')
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 1, '')) + char(10)
		SET @sql += ') AS MERGE_OUT' + char(10)
		SET @sql += 'WHERE MERGE_OUT.Action_Out = ''Update'';' + char(10)
		
	END
	ELSE BEGIN
		SET @sql += 'MERGE [' + @table_schema + '].[' + @table_name + '] T' + char(10)
		SET @sql += 'USING [' + @schemaName + '].[' + @table_name + '] S' + char(10)	
		SET @sql += 'ON (T.[' + @primaryKey + '] = S.[' + @primaryKey + '])' + char(10)
		SET @sql += 'WHEN NOT MATCHED THEN' + char(10)
		SET @sql += 'INSERT VALUES (' + (SELECT STUFF((SELECT ',S.' + CAST('[' + Column_Name + '] ' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 1, '')) + ')' + char(10)
	

		SET @sql += 'WHEN MATCHED THEN' + char(10)
		SET @sql += 'UPDATE SET' + char(10)
		SET @sql += (SELECT STUFF((SELECT ',T.' + CAST('[' + Column_Name + '] = S.' + '[' + Column_Name + ']' as nvarchar(max))
				FROM Information_schema.columns C
				WHERE C.Table_Schema = @schemaName AND C.Table_name = @table_name
				ORDER BY C.ORDINAL_POSITION 
				FOR XML PATH('')
			), 1, 3, '')) + ';'+ char(10)
	END

	PRINT @sql

fetch next from T into @table_name, @table_schema
end

close T
deallocate T