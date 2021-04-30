CREATE PROCEDURE [shared].[DisableForeignKey]
(
	@db nvarchar(64)
	, @ForeignKey nvarchar(128)
	, @enable bit = 0
)
AS
BEGIN

-- https://www.mssqltips.com/sqlservertip/3347/drop-and-recreate-all-foreign-key-constraints-in-sql-server/
-- https://stackoverflow.com/questions/159038/how-can-foreign-key-constraints-be-temporarily-disabled-using-t-sql

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @enable = 1
	EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLString nvarchar(max) = ''

SET @SQLString += '
DECLARE @ForeignKey nvarchar(128)
DECLARE @SQLStringDrop nvarchar(max)
DECLARE @SQLStringAdd nvarchar(max)

SELECT TOP 1
	@ForeignKey = fk.[name]'

	-- Dropping is easy; just build statements from sys.foreign_keys
	SET @SQLString += '
	, @SQLStringDrop = ''ALTER TABLE ' + @db + '.'' + QUOTENAME(cs.[name]) + ''.'' + QUOTENAME(ct.[name]) + '' DROP CONSTRAINT '' + QUOTENAME(fk.[name])'

	-- Recreating foreign keys is a little more complex. We need to generate the list of columns on both sides of the
	-- constraint, even though in most cases there is only one column.
	SET @SQLString += '
	, @SQLStringAdd = ''ALTER TABLE ' + @db + '.'' + QUOTENAME(cs.[name]) + ''.'' + QUOTENAME(ct.[name]) + '' ADD CONSTRAINT '' + QUOTENAME(fk.[name])
	
		+ '' FOREIGN KEY ('' + STUFF(('

		-- Get all the columns in the constraint table
		SET @SQLString += '
		SELECT '','' + QUOTENAME(c.[name])
		FROM ' + @db + '.sys.columns c INNER JOIN ' + @db + '.sys.foreign_key_columns fkc ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id
		FOR XML PATH ('''')), 1, 1, '''')
		+ '')''

		+ '' REFERENCES '' + QUOTENAME(rs.[name]) + ''.'' + QUOTENAME(rt.[name]) + '' ('' + STUFF(('

		-- Get all the referenced columns
		SET @SQLString += '
		SELECT '','' + QUOTENAME(c.[name])
		FROM ' + @db + '.sys.columns c INNER JOIN ' + @db + '.sys.foreign_key_columns fkc ON fkc.referenced_column_id = c.column_id AND fkc.referenced_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id
		FOR XML PATH ('''')), 1, 1, '''')
		+ '')''
FROM
	' + @db + '.sys.foreign_keys fk
	INNER JOIN ' + @db + '.sys.tables ct ON fk.parent_object_id = ct.[object_id]' /* constraint table */ + '
	INNER JOIN ' + @db + '.sys.schemas cs ON ct.[schema_id] = cs.[schema_id]
	INNER JOIN ' + @db + '.sys.tables rt ON fk.referenced_object_id = rt.[object_id]' /* referenced table */ + '
	INNER JOIN ' + @db + '.sys.schemas rs ON rt.[schema_id] = rs.[schema_id]
WHERE 1=1
	AND fk.[name] = ''' + @ForeignKey + '''
	
EXEC (@SQLStringDrop)

INSERT INTO
	shared.ForeignKeys
	(
	DbName
	, ForeignKey
	, SQLStringAdd
	)
SELECT
	''' + @db + '''
	, @ForeignKey
	, @SQLStringAdd'

EXEC (@SQLString)

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' successful...'
IF @enable = 1
	EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = CASE WHEN @enable = 0 THEN 'Disabling' ELSE 'Enabling' END + ' ' + @ForeignKey + ' FAILED...'
IF @enable = 1
	EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END

/*
EXEC shared.DisableForeignKey '[TOPdesk_DW]', 'FK_Incident_ObjectKey', 0
*/