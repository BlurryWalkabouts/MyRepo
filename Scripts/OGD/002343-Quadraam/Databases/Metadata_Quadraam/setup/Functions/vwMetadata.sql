CREATE FUNCTION [setup].[vwMetadata]
(
	@patDataSource varchar(10)
	, @patConnector nvarchar(64)
)
RETURNS table
AS
RETURN
(

WITH cte AS
(
SELECT
	DataSource
	, Connector
	, OriginalColumnName
	, TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, ORDINAL_POSITION
FROM
	setup.vwMetadataAfas

UNION

SELECT
	DataSource
	, Connector
	, OriginalColumnName
	, TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, ORDINAL_POSITION
FROM
	setup.vwMetadataDUO

UNION

SELECT
	DataSource
	, Connector
	, OriginalColumnName
	, TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, ORDINAL_POSITION
FROM
	setup.vwMetadataMagister
)

SELECT
	DataSource
	, Connector
	, OriginalColumnName
	, TABLE_NAME
	, COLUMN_NAME
	, DATA_TYPE
	, ORDINAL_POSITION
FROM
	cte
WHERE 1=1
	AND DataSource LIKE @patDataSource
	AND Connector LIKE @patConnector

)