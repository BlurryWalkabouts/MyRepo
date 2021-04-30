CREATE VIEW [setup].[vwMetadataTables]
AS
SELECT DISTINCT
	TABLE_SCHEMA = DataSource
	, TABLE_NAME
	, Connector
	, CREATE_SELECT = CASE WHEN DATA_TYPE IS NOT NULL THEN 'CREATE' ELSE 'SELECT' END
	, RowsResults = CASE DataSource WHEN 'DUO' THEN 'results' WHEN 'Afas' THEN 'rows' END
	, ExtraColumnDefinitions = CASE DataSource WHEN 'DUO' THEN char(10) + char(9) + ', Jaar char(9) NULL' ELSE '' END
	, ExtraColumns = CASE DataSource WHEN 'DUO' THEN char(10) + char(9) + ', Jaar' ELSE '' END
	, ExtraApply = CASE DataSource WHEN 'DUO' THEN char(10) + char(9) + 'CROSS APPLY setup.TransformTableNameDUO(j.Connector)' ELSE '' END
FROM
	setup.Metadata