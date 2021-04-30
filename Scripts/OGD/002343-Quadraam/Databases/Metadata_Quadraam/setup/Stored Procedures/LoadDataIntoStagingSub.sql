CREATE PROCEDURE [setup].[LoadDataIntoStagingSub]
(
	@schema varchar(64)
	, @table varchar(64)
	, @debug bit = 0
)
AS
BEGIN

SET NOCOUNT ON

DECLARE @SQLString nvarchar(max)

SELECT
	@SQLString = N'TRUNCATE TABLE [$(Staging_Quadraam)].' + t1.TABLE_SCHEMA + '.' + t1.TABLE_NAME + '

INSERT INTO
	[$(Staging_Quadraam)].' + t1.TABLE_SCHEMA + '.' + t1.TABLE_NAME + '
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME
		FROM [$(Staging_Quadraam)].INFORMATION_SCHEMA.COLUMNS c
		WHERE t1.TABLE_SCHEMA = c.TABLE_SCHEMA AND t1.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
	)
SELECT
	w.*' + t2.ExtraColumns + '
FROM
	[$(Staging_Quadraam)].setup.DataObjects j
	CROSS APPLY OPENJSON(j.BulkColumn, ''lax $.' + t2.RowsResults + ''') k
	CROSS APPLY OPENJSON(k.[value]) WITH
	(
	' + STUFF((
		SELECT char(10) + char(9) + ', ' + c.COLUMN_NAME + ' ' + c.DATA_TYPE + ' ''$."' + c.OriginalColumnName + '"'''
		FROM setup.vwMetadataColumns c
		WHERE t1.TABLE_SCHEMA = c.TABLE_SCHEMA AND t1.TABLE_NAME = c.TABLE_NAME
		ORDER BY c.ORDINAL_POSITION
		FOR XML PATH('')), 1, 4, '') + '
	) w' + t2.ExtraApply + '
WHERE 1=1
	AND j.DataSource = ''' + t1.TABLE_SCHEMA + '''
	AND j.ContentType = ''Data''
	AND j.Connector LIKE ''' + t2.Connector + '''' + char(10)
FROM
	[$(Staging_Quadraam)].INFORMATION_SCHEMA.TABLES t1
	LEFT OUTER JOIN setup.vwMetadataTables t2 ON t1.TABLE_SCHEMA = t2.TABLE_SCHEMA AND t1.TABLE_NAME = t2.TABLE_NAME
WHERE 1=1
	AND t1.TABLE_SCHEMA = @schema
	AND t1.TABLE_NAME = @table

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END