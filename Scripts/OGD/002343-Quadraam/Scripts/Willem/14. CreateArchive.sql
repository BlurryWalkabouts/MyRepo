--2017-10-02

DECLARE @schema nvarchar(64) = 'Afas'
DECLARE @pattern nvarchar(64) = 'DWH_FIN_%'

SELECT
	SQLString = 'CREATE TABLE [Archive_Quadraam].' + TABLE_SCHEMA + '.' + TABLE_NAME + ' (' + STUFF((
		SELECT ', ' + COLUMN_NAME + ' ' + DATA_TYPE + ' NULL'
		FROM [Metadata_Quadraam].setup.MetadataAfas c
		WHERE t.TABLE_NAME = c.Connector
		ORDER BY c.FieldID
		FOR XML PATH('')), 1, 2, '') + '
		, ValidFrom datetime2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_' + TABLE_NAME + '_ValidFrom] DEFAULT CAST(''0000-01-01 00:00:00'' AS datetime2(0)) NOT NULL
		, ValidTo datetime2 (0) GENERATED ALWAYS AS ROW END HIDDEN CONSTRAINT [DF_' + TABLE_NAME + '_ValidTo] DEFAULT CAST(''9999-12-31 23:59:59'' AS datetime2(0)) NOT NULL
		, CONSTRAINT [PK_' + TABLE_NAME + '] PRIMARY KEY CLUSTERED (ASC) WITH (DATA_COMPRESSION = PAGE)
		, PERIOD FOR SYSTEM_TIME (ValidFrom, ValidTo)
		)
		WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=history.' + TABLE_NAME + ', DATA_CONSISTENCY_CHECK=ON));
		
CREATE CLUSTERED INDEX [IX_' + TABLE_NAME + '] ON history.' + TABLE_NAME + ' (ValidTo ASC, ValidFrom ASC)'
FROM
	[Staging_Quadraam].INFORMATION_SCHEMA.TABLES t
WHERE 1=1
	AND TABLE_SCHEMA = @schema
	AND TABLE_NAME LIKE @pattern

/*
EXEC Metadata_Quadraam.shared.DisableVersioning 'Archive_Quadraam','Afas','DWH_FIN_Administraties'
DROP TABLE [Archive_Quadraam].Afas.DWH_FIN_Administraties
DROP TABLE [Archive_Quadraam].history.DWH_FIN_Administraties
*/