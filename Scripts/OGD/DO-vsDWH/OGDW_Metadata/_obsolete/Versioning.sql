CREATE PROCEDURE [etl].[Versioning]
(
	@status bit
	, @tablename varchar(max)
	, @debug bit = 0
)
AS
BEGIN

DECLARE @SQLString nvarchar(max)
DECLARE @db varchar(max) = 'OGDW_Archive'

IF @status = 0
	SET @SQLString = '
		ALTER TABLE ' + @db + '.' + @tablename + ' SET (SYSTEM_VERSIONING = OFF)
		ALTER TABLE ' + @db + '.' + @tablename + ' DROP PERIOD FOR SYSTEM_TIME'

IF @status = 1
	SET @SQLString = '
		ALTER TABLE ' + @db + '.' + @tablename + ' ADD PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
		ALTER TABLE ' + @db + '.' + @tablename + ' SET (SYSTEM_VERSIONING = ON (HISTORY_TABLE = history.' + SUBSTRING(@tablename, CHARINDEX('.',@tablename) + 1, LEN(@tablename)) + '))
		ALTER TABLE ' + @db + '.' + @tablename + ' ALTER COLUMN ValidFrom ADD HIDDEN
		ALTER TABLE ' + @db + '.' + @tablename + ' ALTER COLUMN ValidTo ADD HIDDEN'

IF @debug = 1
	PRINT (@SQLString)
ELSE
	EXEC (@SQLString)

END