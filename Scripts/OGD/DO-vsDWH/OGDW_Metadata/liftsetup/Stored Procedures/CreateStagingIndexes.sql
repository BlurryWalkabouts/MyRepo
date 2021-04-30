CREATE PROCEDURE [liftsetup].[CreateStagingIndexes]
(
	@debug bit = 0
)
AS
BEGIN

/* Index op unid aanmaken voor iedere staging table: */

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)
DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))

DECLARE c CURSOR FOR
(
SELECT TABLE_NAME
FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES
WHERE TABLE_SCHEMA = @staging_schema AND TABLE_TYPE = 'BASE TABLE'
)
ORDER BY TABLE_NAME

DECLARE @table_name sysname

OPEN c
FETCH NEXT FROM c INTO @table_name
WHILE @@FETCH_STATUS = 0
BEGIN
	PRINT 'Creating index for ' + @table_name

	-- Drop existing index:
	SET @SQLString = 'DROP INDEX IF EXISTS [IX_' + @staging_schema + '_' + @table_name + '_unid] ON [' + @staging_schema + '].[' + @table_name + ']'

	IF @debug = 0
		EXEC [$(LIFT_Staging)].sys.sp_executesql @SQLString
	ELSE
		PRINT @SQLString

	SET @SQLString = '
		CREATE UNIQUE CLUSTERED INDEX [IX_' + @staging_schema + '_' + @table_name + '_unid] ON [' + @staging_schema + '].[' + @table_name + ']
		(
			[unid] ASC
		)
		WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, SORT_IN_TEMPDB = OFF, IGNORE_DUP_KEY = OFF, DROP_EXISTING = OFF, ONLINE = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]'

	BEGIN TRY
		IF @debug = 0
			EXEC [$(LIFT_Staging)].sys.sp_executesql @SQLString
		ELSE
			PRINT @SQLString
	END TRY
	BEGIN CATCH
		Print 'ERROR: ' + @@ERROR -- Meestal ontbrekende unid
	END CATCH

	FETCH NEXT FROM c INTO @table_name
END 

CLOSE c
DEALLOCATE c

END