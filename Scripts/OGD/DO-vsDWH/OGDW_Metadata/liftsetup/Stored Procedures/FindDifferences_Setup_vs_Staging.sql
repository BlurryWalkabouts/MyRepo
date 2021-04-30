CREATE PROCEDURE [liftsetup].[FindDifferences_Setup_vs_Staging]
AS
BEGIN

-- ========================================================================
-- Author: Mark Versteegh
-- Creation date: 20161122
-- Description: Zoekt de verschillen tussen de setup in LIFT_Staging en LIFT_Staging zelf
-- ========================================================================

DECLARE @staging_schema sysname = CONCAT('Lift', (SELECT lift_version FROM lift.dbo_version))

/* Verschillen tussen tabellen */

-- Tabellen wel in setup, niet in staging
DECLARE @new_tables table (TABLE_NAME sysname, import int)

INSERT INTO @new_tables (TABLE_NAME)
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 0 AND import = 1
EXCEPT
SELECT TABLE_NAME FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = @staging_schema

-- Tabellen wel in staging, niet in setup
DECLARE @old_tables table (TABLE_NAME sysname)

INSERT INTO @old_tables (TABLE_NAME)
SELECT TABLE_NAME FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = @staging_schema
EXCEPT
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 0 AND import = 1

-- Zoek de huidige import status op van de nieuwe tabellen (zou natuurlijk 1 moeten zijn)
UPDATE
	N
SET
	import = T.import
FROM
	@new_tables N
	JOIN [$(LIFT_Staging)].setup.DWTables T ON N.TABLE_NAME = T.TABLE_NAME AND T.deleted = 0

-- Geef het resultaat weer
SELECT [oud/nieuw] = 'Tabel alleen in setup', TABLE_NAME, import FROM @new_tables
UNION
SELECT [oud/nieuw] = 'Tabel alleen in staging', TABLE_NAME, import = NULL FROM @old_tables

/* Verschillen tussen kolommen */

-- Kolommen wel in setup, niet in staging, exclusief nieuwe tabellen
DECLARE @new_columns table ([oud/nieuw] varchar(50), TABLE_NAME sysname, COLUMN_NAME sysname, import int)

INSERT INTO
	@new_columns ([oud/nieuw], TABLE_NAME, COLUMN_NAME)
SELECT
	[oud/nieuw] = 'Kolom alleen in setup'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].setup.DWColumns 
WHERE 1=1
	AND deleted = 0
	AND import = 1
	AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM @new_tables)
EXCEPT
SELECT
	[oud/nieuw] = 'Kolom alleen in setup'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @staging_schema

-- Kolommen wel in staging, niet in setup
DECLARE @old_columns table ([oud/nieuw] varchar(50), TABLE_NAME sysname, COLUMN_NAME sysname, import int)

INSERT INTO
	@old_columns ([oud/nieuw], TABLE_NAME, COLUMN_NAME)
SELECT
	[oud/nieuw] = 'Kolom alleen in staging'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = @staging_schema
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = @staging_schema)
	AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM @old_tables)
	AND COLUMN_NAME <> 'LiftAuditDWKey'
EXCEPT
SELECT
	[oud/nieuw] = 'Kolom alleen in staging'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].setup.DWColumns
WHERE 1=1
	AND deleted = 0
	AND import = 1

-- Zoek de huidige import status op van de nieuwe kolommen (zou natuurlijk 1 moeten zijn)
UPDATE
	N
SET
	import = C.import
FROM
	@new_columns N
	JOIN [$(LIFT_Staging)].setup.DWColumns C ON N.TABLE_NAME = C.TABLE_NAME AND N.COLUMN_NAME = C.COLUMN_NAME AND C.deleted = 0

-- Geef het resultaat weer
SELECT * FROM @new_columns
UNION
SELECT * FROM @old_columns

/* Gewijzigde kolommen */

;WITH x AS
(
SELECT
	TABLE_NAME
	, COLUMN_NAME
	, column_fulltype = CASE
			WHEN DATA_TYPE = 'ntext' THEN 'nvarchar(max)'
			WHEN DATA_TYPE = 'text' THEN 'varchar(max)'
			ELSE DATA_TYPE --(n)text vervangen we bij ons door (n)varchar(max)
				+ CASE
					WHEN DATA_TYPE IN ('varchar', 'char', 'varbinary', 'binary', 'nvarchar', 'nchar')
						THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'max' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(5)) END + ')'
					WHEN DATA_TYPE IN ('datetime2', 'time2', 'datetimeoffset')
						THEN '(' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
					WHEN DATA_TYPE = 'decimal'
						THEN '(' + CAST(NUMERIC_PRECISION AS varchar(5)) + ',' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
					ELSE ''
				END 
		END
FROM
	[$(LIFT_Staging)].INFORMATION_SCHEMA.COLUMNS
WHERE 1=1
	AND TABLE_SCHEMA = 'dbo' 
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM [$(LIFT_Staging)].INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo')
)

SELECT
	'Gewijzigde kolom'
	, y.id
	, y.TABLE_NAME
	, y.TABLE_NAME
	, column_fulltype_setup = y.column_fulltype
	, column_fulltype_staging = x.column_fulltype
	, y.import
	, y.keep_history
	, y.compare
	, y.comment
	, y.deleted
	, y.datecreated
FROM
	x 
	INNER JOIN [$(LIFT_Staging)].setup.DWColumns y ON x.TABLE_NAME = y.TABLE_NAME AND x.COLUMN_NAME = y.COLUMN_NAME AND x.column_fulltype <> y.column_fulltype
WHERE 1=1
	AND y.deleted = 0
	AND y.import = 1

END