CREATE PROCEDURE [liftetl].[CompareChecksums]
(
	@staging_schema sysname
	, @table_name sysname
	, @debug bit = 0
)
AS
BEGIN

/*
Checksum over decimal/numeric velden werkt niet goed, want checksum(1.0) = checksum(10.0), er wordt geen rekening gehouden met de positie van de komma.
LIFT gebruikt deze types niet, in plaats daarvan gebruiken ze overal money
*/

--DECLARE @table_name sysname = 'contactnotecustomercontact'
DECLARE @staging_full_schema sysname = '[$(LIFT_Staging)].' + @staging_schema
DECLARE @source_full_schema sysname = '[$(LIFTServer)].[$(LIFT5)].dbo'

DECLARE @columns nvarchar(max) = ''

SELECT
	@columns +=  ', '  + QUOTENAME(COLUMN_NAME)
FROM
	[$(LIFT_Staging)].setup.DWColumns
WHERE 1=1
	AND TABLE_NAME = @table_name
	AND import = 1 
	AND compare = 1 -- Over (n)text velden kunnen we geen checksum bepalen, dus die vergelijken we hier niet

SET @columns = RIGHT(@columns, LEN(@columns)-1) -- Remove comma

DECLARE @c1 int
DECLARE @c2 int -- Checksums

DECLARE @SQLString nvarchar(max)

SET @SQLString = '
SELECT
	@chk = CHECKSUM_AGG(BINARY_CHECKSUM(' + @columns + '))
FROM
	' + @staging_full_schema + '.' + QUOTENAME(@table_name)

IF @debug = 0
	EXEC sp_executesql @SQLString, N'@chk int OUTPUT', @chk = @c1 OUTPUT
ELSE
	PRINT @SQLString

-- Zelfde nog een keer, maar dan voor source ipv staging:
SET @SQLString = '
SELECT
	@chk = CHECKSUM_AGG(BINARY_CHECKSUM(' + @columns + '))
FROM
	' + @source_full_schema + '.' + QUOTENAME(@table_name)

IF @debug = 0
	EXEC sp_executesql @SQLString, N'@chk int OUTPUT', @chk = @c2 OUTPUT
ELSE
	PRINT @SQLString

IF COALESCE(@c1,-1) = COALESCE(@c2,-2)
	RETURN 1
ELSE
	RETURN 0

END

/*
DECLARE @ok bit
EXEC @ok = liftetl.CompareChecksums 'Lift212', 'workflowemployeecontract', 1
PRINT @ok
*/