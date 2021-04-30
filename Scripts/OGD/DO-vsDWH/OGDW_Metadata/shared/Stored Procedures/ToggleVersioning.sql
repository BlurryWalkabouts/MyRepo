CREATE PROCEDURE [shared].[ToggleVersioning]
(
	@db nvarchar(64)
	, @schema nvarchar(64)
	, @table nvarchar(64)
	, @enable bit
	, @debug bit = 0
)
AS
BEGIN

DECLARE @SQLString nvarchar(max)

IF @enable = 0 SET @SQLString = '
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' SET (SYSTEM_VERSIONING = OFF)
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' DROP PERIOD FOR SYSTEM_TIME'

ELSE SET @SQLString = '
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' ADD PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.' + @table + ', DATA_CONSISTENCY_CHECK = ON))
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' REBUILD PARTITION = ALL WITH (DATA_COMPRESSION = PAGE)
' + CASE WHEN @schema <> 'FileImport' THEN '
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' ALTER COLUMN ValidFrom ADD HIDDEN
ALTER TABLE ' + @db + '.' + @schema + '.' + @table + ' ALTER COLUMN ValidTo ADD HIDDEN'
ELSE '' END

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END