--SELECT DISTINCT Connector FROM setup.MetadataAfas

DECLARE @dir nvarchar(64) = 'F:\JSON\'
DECLARE @file nvarchar(64) = 'DWH_FIN_Crediteuren'

DECLARE @SQLString nvarchar(max)

SELECT
	@SQLString = N'TRUNCATE TABLE Staging_Quadraam.Afas.' + @file + '

INSERT INTO
	Staging_Quadraam.Afas.' + @file + '
	(
	' + STUFF((
		SELECT ', ' + COLUMN_NAME
		FROM Staging_Quadraam.INFORMATION_SCHEMA.COLUMNS c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY ORDINAL_POSITION
		FOR XML PATH('')), 1, 2, '') + '
	)
SELECT
	w.*
FROM
	OPENROWSET (BULK ''' + @dir + @file + '.json'', SINGLE_NCLOB) j
	CROSS APPLY OPENJSON(j.BulkColumn, ''strict $.rows'') k
	CROSS APPLY OPENJSON(k.[value])
WITH
	(
	' + STUFF((
		SELECT ', ' + COLUMN_NAME + ' ' + DATA_TYPE + CASE
				WHEN DATA_TYPE = 'datetime2' THEN '(' + CAST(DATETIME_PRECISION AS varchar(5)) + ')'
				WHEN DATA_TYPE = 'decimal' THEN '(' + CAST(NUMERIC_PRECISION AS varchar(5)) + ',' + CAST(NUMERIC_SCALE AS varchar(5)) + ')'
				WHEN DATA_TYPE = 'nvarchar' THEN '(' + CASE WHEN CHARACTER_MAXIMUM_LENGTH = -1 THEN 'max' ELSE CAST(CHARACTER_MAXIMUM_LENGTH AS varchar(5)) END + ')'
				ELSE ''
			END
		FROM Staging_Quadraam.INFORMATION_SCHEMA.COLUMNS c
		WHERE t.TABLE_SCHEMA = c.TABLE_SCHEMA AND t.TABLE_NAME = c.TABLE_NAME
		ORDER BY ORDINAL_POSITION
		FOR XML PATH('')), 1, 2, '') + '
	) w'
FROM
	Staging_Quadraam.INFORMATION_SCHEMA.TABLES t
WHERE 1=1
	AND TABLE_SCHEMA = 'Afas'
	AND TABLE_NAME = @file

PRINT (@SQLString)