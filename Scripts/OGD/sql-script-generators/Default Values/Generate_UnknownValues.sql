DECLARE @sql nvarchar(max);
SET @sql = (SELECT STUFF((
				SELECT ',' + (
					CASE WHEN DATA_TYPE = 'bit' THEN '0'
						 WHEN DATA_TYPE IN ('tinyint', 'bigint', 'int', 'smallint') THEN '-1'
						 WHEN DATA_TYPE = 'uniqueidentifier' THEN '00000000-0000-0000-0000-000000000000'
						 WHEN DATA_TYPE IN ('money', 'numeric') THEN '0'
						 WHEN DATA_TYPE = 'time' THEN '00:00:00'
						 WHEN DATA_TYPE IN ('date', 'datetime2', 'datetime') THEN '9999-12-31' 
						 WHEN DATA_TYPE = 'nvarchar' THEN '[Unknown]'
						 ELSE NULL
					END
				)
			FROM Information_schema.columns C
			ORDER BY C.ORDINAL_POSITION 
			FOR XML PATH('')
		), 1, 1, ''))


print @sql
