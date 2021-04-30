CREATE PROCEDURE [liftsetup].[FindDifferences_LIFT_vs_Setup]
AS
BEGIN

-- ========================================================================
-- Author: Mark Versteegh
-- Creation date: 20161122
-- Description: Zoekt de verschillen tussen LIFT en de setup in LIFT_Staging
-- ========================================================================

/* Verschillen tussen tabellen */

-- Tabellen wel in LIFT, niet in setup
DECLARE @new_tables table (TABLE_NAME sysname)

INSERT INTO @new_tables (TABLE_NAME)
SELECT TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS FROM lift.information_schema_tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo'
EXCEPT
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 0

-- Tabellen wel in setup, niet in LIFT
DECLARE @old_tables table (TABLE_NAME sysname, import int)

INSERT INTO @old_tables (TABLE_NAME)
SELECT TABLE_NAME FROM [$(LIFT_Staging)].setup.DWTables WHERE deleted = 0
EXCEPT
SELECT TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS FROM lift.information_schema_tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo'

-- Zoek de huidige import status op van de verwijderde tabellen
UPDATE
	O
SET
	import = T.import
FROM
	@old_tables O
	JOIN [$(LIFT_Staging)].setup.DWTables T ON O.TABLE_NAME = T.TABLE_NAME AND T.deleted = 0

-- Geef het resultaat weer
SELECT [oud/nieuw] = 'Toegevoegde tabel in LIFT', TABLE_NAME, import = NULL FROM @new_tables
UNION
SELECT [oud/nieuw] = 'Verwijderde tabel uit LIFT', TABLE_NAME, import FROM @old_tables

/* Verschillen tussen kolommen */

-- Kolommen wel in LIFT, niet in setup, exclusief nieuwe tabellen
DECLARE @new_columns table([oud/nieuw] varchar(50), TABLE_NAME sysname, COLUMN_NAME sysname, import int)

INSERT INTO
	@new_columns ([oud/nieuw], TABLE_NAME, COLUMN_NAME)
SELECT
	[oud/nieuw] = 'Nieuwe kolom in LIFT'
	, TABLE_NAME = TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	, COLUMN_NAME = COLUMN_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
FROM
	lift.information_schema_columns
WHERE 1=1
	AND TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM lift.information_schema_tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo')
	AND TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS NOT IN (SELECT TABLE_NAME FROM @new_tables)
EXCEPT
SELECT
	[oud/nieuw] = 'Nieuwe kolom in LIFT'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].setup.DWColumns
WHERE 1=1
	AND deleted = 0

-- Kolommen wel in setup, niet in LIFT
DECLARE @old_columns table ([oud/nieuw] varchar(50), TABLE_NAME sysname, COLUMN_NAME sysname, import int)

INSERT INTO
	@old_columns ([oud/nieuw], TABLE_NAME, COLUMN_NAME)
SELECT
	[oud/nieuw] = 'Verwijderde kolom uit LIFT'
	, TABLE_NAME
	, COLUMN_NAME
FROM
	[$(LIFT_Staging)].setup.DWColumns
WHERE 1=1
	AND deleted = 0
	AND TABLE_NAME NOT IN (SELECT TABLE_NAME FROM @old_tables)
EXCEPT
SELECT
	[oud/nieuw] = 'Verwijderde kolom uit LIFT'
	, TABLE_NAME = TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	, COLUMN_NAME = COLUMN_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
FROM
	lift.information_schema_columns
WHERE 1=1
	AND TABLE_SCHEMA = 'dbo'

-- Zoek de huidige import status op van de verwijderde kolommen
UPDATE
	O
SET
	import = C.import
FROM
	@old_columns O
	JOIN [$(LIFT_Staging)].setup.DWColumns C ON O.TABLE_NAME = C.TABLE_NAME AND O.COLUMN_NAME = C.COLUMN_NAME AND C.deleted = 0

-- Geef het resultaat weer
SELECT * FROM @new_columns
UNION
SELECT * FROM @old_columns

/* Setup bijwerken */

DECLARE @version nvarchar(20) = (SELECT lift_version FROM lift.dbo_version)

-- Nieuwe tabellen
INSERT INTO
	[$(LIFT_Staging)].setup.DWTables (TABLE_NAME, import, comment)
SELECT
	TABLE_NAME
	, import = 0
	, comment = CONCAT('lift_version: ', @version)
FROM
	@new_tables

-- Verwijderde tabellen
UPDATE
	[$(LIFT_Staging)].setup.DWTables
SET
	deleted = 1
	, import = 0
	, comment = CONCAT('deleted in lift_version ', @version)
WHERE 1=1
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM @old_tables)

-- Bijbehorende kolommen
UPDATE
	[$(LIFT_Staging)].setup.DWColumns
SET
	deleted = 1
	, import = 0
	, comment = CONCAT('table deleted in lift_version ', @version)
WHERE 1=1
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM @old_tables)

-- Verwijderde kolommen
UPDATE
	c
SET
	deleted = 1
	, import = 0
	, comment = CONCAT('column deleted in lift_version', @version)
FROM
	[$(LIFT_Staging)].setup.DWColumns c
	JOIN @old_columns o ON c.TABLE_NAME = o.TABLE_NAME AND c.COLUMN_NAME = o.COLUMN_NAME

-- Nieuwe kolommen
INSERT INTO
	[$(LIFT_Staging)].setup.DWColumns (TABLE_NAME, COLUMN_NAME, column_fulltype, ordinal_position, import, keep_history, compare, comment)
SELECT
	c.TABLE_NAME
	, c.COLUMN_NAME
	, column_fulltype = DATA_TYPE + CASE
			WHEN DATA_TYPE IN ('varchar', 'char', 'varbinary', 'binary', 'nvarchar', 'nchar')
				THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'max' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(5)) END + ')'
			WHEN DATA_TYPE IN ('datetime2', 'time2', 'datetimeoffset')
				THEN '(' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
			WHEN DATA_TYPE = 'decimal'
				THEN '(' + CAST(NUMERIC_PRECISION AS varchar(5)) + ',' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
			ELSE ''
		END
	, ordinal_position = n.ORDINAL_POSITION
	, import = 0
	, keep_history = 1
	, compare = 1
	, comment = CONCAT('added in lift_version', @version)
FROM
	@new_columns c
	JOIN lift.information_schema_columns n ON c.TABLE_NAME = n.TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS AND c.COLUMN_NAME = n.COLUMN_NAME COLLATE SQL_Latin1_General_CP1_CI_AS

/* Gewijzigde kolommen */

;WITH x AS
(
SELECT
	TABLE_NAME = TABLE_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	, COLUMN_NAME = COLUMN_NAME COLLATE SQL_Latin1_General_CP1_CI_AS
	, column_fulltype = CASE
			WHEN DATA_TYPE = 'ntext' THEN 'nvarchar(max)'
			WHEN DATA_TYPE = 'text' THEN 'varchar(max)'
			ELSE DATA_TYPE -- (n)text vervangen we bij ons door (n)varchar(max)
				+ CASE
					WHEN DATA_TYPE IN ('varchar', 'char', 'varbinary', 'binary', 'nvarchar', 'nchar')
						THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'MAX' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(5)) END + ')'
					WHEN DATA_TYPE IN ('datetime2', 'time2', 'datetimeoffset')
						THEN '(' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
					WHEN DATA_TYPE = 'decimal' 
						THEN '(' + CAST(NUMERIC_PRECISION AS varchar(5)) + ',' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
					ELSE ''
				END 
		END COLLATE SQL_Latin1_General_CP1_CI_AS
FROM
	lift.information_schema_columns
WHERE 1=1
	AND TABLE_SCHEMA = 'dbo'
	AND TABLE_NAME IN (SELECT TABLE_NAME FROM lift.information_schema_tables WHERE TABLE_TYPE = 'BASE TABLE' AND TABLE_SCHEMA = 'dbo')
)

SELECT
	'Gewijzigde kolom'
	, y.id
	, y.TABLE_NAME
	, y.COLUMN_NAME
	, column_fulltype_old = y.column_fulltype
	, column_fulltype_new = x.column_fulltype
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

END