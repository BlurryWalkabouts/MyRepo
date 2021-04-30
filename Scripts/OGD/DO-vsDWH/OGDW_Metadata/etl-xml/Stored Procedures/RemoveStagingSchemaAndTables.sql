CREATE PROCEDURE [etl].[RemoveStagingSchemaAndTables]
(
	@staging_schema nvarchar(max)
	, @debug bit = 0
)
AS
BEGIN

/* Verwijder alle tabellen in het (tijdelijke) schema */

DECLARE T CURSOR FOR
(
SELECT TABLE_NAME
FROM [$(OGDW_Staging)].INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @staging_schema
)

DECLARE @table_name sysname
DECLARE @SQLString nvarchar(max)

OPEN T
FETCH NEXT FROM T INTO @table_name

WHILE @@FETCH_STATUS = 0
BEGIN
	SET @SQLString = 'DROP TABLE ' + QUOTENAME(@staging_schema) + '.' + QUOTENAME(@table_name)

	IF @debug = 0
		EXEC [$(OGDW_Staging)].dbo.sp_executesql @SQLString
	ELSE
		PRINT @SQLString

	FETCH NEXT FROM T INTO @table_name
END

CLOSE T
DEALLOCATE T

/* Verwijder het (tijdelijke) schema */

SET @SQLString = 'DROP SCHEMA ' + @staging_schema

IF @debug = 0
	EXEC [$(OGDW_Staging)].dbo.sp_executesql @SQLString
ELSE
	PRINT @SQLString

END