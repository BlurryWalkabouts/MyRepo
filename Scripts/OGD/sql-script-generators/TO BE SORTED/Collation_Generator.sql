	SELECT 
		 t.name AS [Table Name]
		,c.name AS [ColumnName]
		,c.is_nullable
		,c.collation_name AS [Collation]
		,'ALTER TABLE [' + h.name + '].' + QUOTENAME(t.name) + char(10) + char(9) + 'ALTER COLUMN [' +  c.name + ']' + s.name + (CASE WHEN s.name  = 'sysname' THEN '' ELSE ' (' + (CASE WHEN c.max_length = -1 OR c.max_length > 4000 THEN 'MAX' ELSE CAST(c.max_length as nvarchar) END) + ')' END) + ' COLLATE SQL_Latin1_General_CP1_CS_AS ' + (CASE WHEN c.is_nullable = 1 THEN 'NULL' ELSE 'NOT NULL' END) + ';' + char(10)
	FROM sys.tables t 
	INNER JOIN 
		sys.schemas h on (h.schema_id = t.schema_id)
	INNER JOIN
       sys.columns c ON c.object_id=t.object_id 
	INNER JOIN
       sys.types s ON s.user_type_id=c.user_type_id
	WHERE c.collation_name LIKE 'Latin1_General_CI_AS'
		AND t.type like 'U'
		AND t.name not like 'spt%'
		AND t.name not like 'MSrep%'
		and c.name NOT IN ('StagingBase', 'TableColumn', 'DisplayName', 'ViewSuffix', 'TableCode', 'Name')
		and c.is_computed = 0