CREATE PROCEDURE [liftetl].[LoadStagingTables]
(
	@debug bit = 0
)
AS
BEGIN

/*
Laadt de data uit LIFT5_Live in LIFT_Staging. 
Het schema in staging is LIFT_[version], deze wordt aangemaakt in de setup

Voor tabellen met een [datwijzig] kunnen we een delta-load doen. Tabellen zonder [datwijzig] worden altijd geheel opnieuw ingelezen.

20170405 database connection aangepast ivm migratie vanuit Azure terug naar on-prem.
*/

SET NOCOUNT ON

INSERT INTO
	[log].LiftAudit (DateImported, BatchStartDate, BatchEndDate)
VALUES
	(NULL, NULL, NULL)

DECLARE @LiftAuditDWKey int = @@IDENTITY

DECLARE @SQLString nvarchar(max)
DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))
DECLARE @source_full_schema sysname = '[$(LIFTServer)].[$(LIFT5)].dbo'

DECLARE c CURSOR FOR
(
SELECT TABLE_NAME
FROM [$(LIFT_Staging)].setup.DWTables
WHERE import = 1
)
ORDER BY TABLE_NAME

DECLARE @table_name sysname
DECLARE @columns nvarchar(max)

DECLARE @ok bit
DECLARE @has_unid bit
DECLARE @has_datwijzig bit
DECLARE @max_datwijzig datetime

OPEN c
FETCH NEXT FROM c INTO @table_name
WHILE @@FETCH_STATUS = 0
BEGIN
   /* Wordt nu verder niet gebruikt, er is maar 1 tabel (version) zonder unid */
	IF EXISTS (SELECT 1 FROM [$(LIFT_Staging)].setup.DWColumns WHERE TABLE_NAME = @table_name AND COLUMN_NAME = 'unid')
		SET @has_unid = 1
	ELSE
		SET @has_unid = 0

	IF EXISTS (SELECT 1 FROM [$(LIFT_Staging)].setup.DWColumns WHERE TABLE_NAME = @table_name AND COLUMN_NAME = 'datwijzig')
		SET @has_datwijzig = 1
	ELSE
		SET @has_datwijzig = 0

	SET @columns = ''

   PRINT 'Load table ' + @staging_schema + '.' + @table_name

	IF @has_datwijzig = 1
	BEGIN
		SET @SQLString = 'SELECT @max = MAX(datwijzig) FROM [$(LIFT_Staging)].' + @staging_schema + '.' + @table_name

		IF @debug = 0
			EXEC sp_executesql @SQLString, N'@max datetime OUTPUT', @max = @max_datwijzig OUTPUT
		ELSE
			PRINT @SQLString

		SET @max_datwijzig = COALESCE(@max_datwijzig, '17530101') -- Vanwege gedoe met lege tabel
		PRINT CONCAT('Max datwijzig: ', @max_datwijzig)
	END

	EXEC @ok = liftetl.CompareChecksums @staging_schema, @table_name

	IF @ok = 1
		PRINT 'Checksums match, table up to date.'
	ELSE
	BEGIN
		/* (extra performance): voor (grote) tabellen met datwijzig kunnen we vrij eenvoudig de nieuwe records vinden
		TODO: checksum over de oude records bepalen ipv over alle records
		als er dan toch verschillen zijn in de oude records dan moet dit door deletes komen (mits topdesk netjes de datwijzig update bij iedere wijziging)
		en om die te detecteren hoeven we alleen de unids in te lezen */

		SELECT
			@columns += CHAR(10) + CHAR(9) + QUOTENAME(COLUMN_NAME) + ','
		FROM
			[$(LIFT_Staging)].setup.DWColumns
		WHERE 1=1
			AND import = 1
			AND TABLE_NAME = @table_name
		
		/* Remove trailing comma */
		SET @columns = LEFT(@columns, LEN(@columns)-1)

		/* NOG AANPASSEN, WE LADEN NU ALLE TABELLEN GEHEEL OPNIEUW */
		IF (@has_datwijzig = 1 AND 0 = 1)

		/* Nu kunnen we een delta-load doen: */
		BEGIN
			/* Geen truncate! */
			SET @SQLString = '
			INSERT INTO
				[$(LIFT_Staging)].' + @staging_schema + '.' + @table_name + '
				(
				[AuditDWKey],' + @columns + '
				)
			SELECT
				' + CAST(@LiftAuditDWKey AS varchar(10)) + ', ' + @columns + '
			FROM
				' + @source_full_schema + '.' + @table_name + '
			WHERE 1=1
				AND datwijzig > @datwijzig'

			IF @debug = 0
				EXEC sp_executesql @SQLString, N'@datwijzig datetime', @datwijzig = @max_datwijzig
			ELSE
				PRINT @SQLString

			/* Verwijderde records? NOG AFHANDELEN */
		END
		ELSE
		BEGIN
			SET @SQLString = '
			TRUNCATE TABLE [$(LIFT_Staging)].' + @staging_schema + '.' + @table_name + '

			INSERT INTO
				[$(LIFT_Staging)].' + @staging_schema + '.' + @table_name + '
				(
				[AuditDWKey],' + @columns + '
				)
			SELECT
				' + CAST(@LiftAuditDWKey AS varchar(10)) + ', ' + @columns + '
			FROM
				' + @source_full_schema + '.' + @table_name
		
			IF @debug = 0
				EXEC (@SQLString)
			ELSE
				PRINT @SQLString
		END
	END
	FETCH NEXT FROM c INTO @table_name
END

CLOSE c
DEALLOCATE c

END