CREATE PROCEDURE [etl].[DisableForeignKey]
(
	@ForeignKey nvarchar(128)
)
AS
BEGIN

-- https://www.mssqltips.com/sqlservertip/3347/drop-and-recreate-all-foreign-key-constraints-in-sql-server/
-- https://stackoverflow.com/questions/159038/how-can-foreign-key-constraints-be-temporarily-disabled-using-t-sql

SET NOCOUNT ON

BEGIN TRY

BEGIN TRANSACTION

DECLARE @SQLStringDrop nvarchar(max)
DECLARE @SQLStringAdd nvarchar(max)

SELECT TOP 1
	-- Dropping is easy; just build statements from sys.foreign_keys
	@SQLStringDrop = 'ALTER TABLE [$(DWH_Quadraam)].' + QUOTENAME(cs.[name]) + '.' + QUOTENAME(ct.[name]) + ' DROP CONSTRAINT ' + QUOTENAME(fk.[name])

	-- Recreating foreign keys is a little more complex. We need to generate the list of columns on both sides of the
	-- constraint, even though in most cases there is only one column.
	, @SQLStringAdd = 'ALTER TABLE [$(DWH_Quadraam)].' + QUOTENAME(cs.[name]) + '.' + QUOTENAME(ct.[name]) + ' ADD CONSTRAINT ' + QUOTENAME(fk.[name])
	
		+ ' FOREIGN KEY (' + STUFF((

		-- Get all the columns in the constraint table
		SELECT ',' + QUOTENAME(c.[name])
		FROM [$(DWH_Quadraam)].sys.columns c INNER JOIN [$(DWH_Quadraam)].sys.foreign_key_columns fkc ON fkc.parent_column_id = c.column_id AND fkc.parent_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id
		FOR XML PATH ('')), 1, 1, '')
		+ ')'

		+ ' REFERENCES ' + QUOTENAME(rs.[name]) + '.' + QUOTENAME(rt.[name]) + ' (' + STUFF((

		-- Get all the referenced columns
		SELECT ',' + QUOTENAME(c.[name])
		FROM [$(DWH_Quadraam)].sys.columns c INNER JOIN [$(DWH_Quadraam)].sys.foreign_key_columns fkc ON fkc.referenced_column_id = c.column_id AND fkc.referenced_object_id = c.[object_id]
		WHERE fkc.constraint_object_id = fk.[object_id]
		ORDER BY fkc.constraint_column_id 
		FOR XML PATH ('')), 1, 1, '')
		+ ')'
FROM
	[$(DWH_Quadraam)].sys.foreign_keys fk
	INNER JOIN [$(DWH_Quadraam)].sys.tables ct ON fk.parent_object_id = ct.[object_id] /* constraint table */
	INNER JOIN [$(DWH_Quadraam)].sys.schemas cs ON ct.[schema_id] = cs.[schema_id]
	INNER JOIN [$(DWH_Quadraam)].sys.tables rt ON fk.referenced_object_id = rt.[object_id] /* referenced table */
	INNER JOIN [$(DWH_Quadraam)].sys.schemas rs ON rt.[schema_id] = rs.[schema_id]
WHERE 1=1
	AND fk.[name] = @ForeignKey

EXEC (@SQLStringDrop)

INSERT INTO
	etl.ForeignKeys
SELECT
	@ForeignKey
	, @SQLStringAdd

COMMIT TRANSACTION

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

END CATCH

END