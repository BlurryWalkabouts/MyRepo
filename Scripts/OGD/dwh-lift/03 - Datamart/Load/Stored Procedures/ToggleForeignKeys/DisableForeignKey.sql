CREATE PROCEDURE [Load].[DisableForeignKey]
(
	@ForeignKey nvarchar(128)
	, @WriteLog bit = 0
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
DECLARE @newMessage nvarchar(max) = 'Disabling ' + @ForeignKey + ' in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DECLARE @SQLStringDrop nvarchar(max)
DECLARE @SQLStringAdd nvarchar(max)

SELECT TOP 1
	-- Dropping is easy; just build statements from sys.foreign_keys
	@SQLStringDrop = 'ALTER TABLE ' + QUOTENAME(cs.[name]) + '.' + QUOTENAME(ct.[name]) + ' DROP CONSTRAINT ' + QUOTENAME(fk.[name])

	-- Recreating foreign keys is a little more complex. We need to generate the list of columns on both sides of the
	-- constraint, even though in most cases there is only one column.
	, @SQLStringAdd = 'ALTER TABLE ' + QUOTENAME(cs.[name]) + '.' + QUOTENAME(ct.[name]) + ' ADD CONSTRAINT ' + QUOTENAME(fk.[name])
	
		+ ' FOREIGN KEY (' + STUFF((

		-- Get all the columns in the constraint table
		SELECT ',' + QUOTENAME(c.[name])
		FROM sys.columns c INNER JOIN sys.foreign_key_columns fkc ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id
		FOR XML PATH ('')), 1, 1, '')
		+ ')'

		+ ' REFERENCES ' + QUOTENAME(rs.[name]) + '.' + QUOTENAME(rt.[name]) + ' (' + STUFF((

		-- Get all the referenced columns
		SELECT ',' + QUOTENAME(c.[name])
		FROM sys.columns c INNER JOIN sys.foreign_key_columns fkc ON fkc.referenced_column_id = c.column_id AND fkc.referenced_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id
		FOR XML PATH ('')), 1, 1, '')
		+ ')'
FROM
	sys.foreign_keys fk
	INNER JOIN sys.tables ct ON fk.parent_object_id = ct.[object_id] /* constraint table */
	INNER JOIN sys.schemas cs ON ct.[schema_id] = cs.[schema_id]
	INNER JOIN sys.tables rt ON fk.referenced_object_id = rt.[object_id] /* referenced table */
	INNER JOIN sys.schemas rs ON rt.[schema_id] = rs.[schema_id]
WHERE 1=1
	AND fk.[name] = @ForeignKey
	
EXEC (@SQLStringDrop)

INSERT INTO
	[Load].ForeignKeys
	(
	ForeignKey
	, SQLStringAdd
	)
SELECT
	@ForeignKey
	, @SQLStringAdd

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Disabling ' + @ForeignKey + ' successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Disabling ' + @ForeignKey + ' FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END