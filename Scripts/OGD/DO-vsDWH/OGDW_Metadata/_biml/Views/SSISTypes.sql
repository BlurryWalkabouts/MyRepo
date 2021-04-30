CREATE VIEW [setup].[SSISTypes]
AS
SELECT
	ID
	, [Name]
	, Code
	, SqlType
	, CastToSSIS
	, BimlType
	, LengthReq
	, PrecisionReq
FROM
	[$(MDS)].mdm.SSIS_Types