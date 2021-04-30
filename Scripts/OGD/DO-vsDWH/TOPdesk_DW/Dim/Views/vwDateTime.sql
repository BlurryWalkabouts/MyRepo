CREATE VIEW [Dim].[vwDateTime]
AS

SELECT
	D.[Date]
	, T.[Time]
	, [datetime] = CAST(CAST([Date] AS char(10)) + ' ' + CAST([Time] AS char(8)) AS datetime2(3))
FROM
	Dim.[Date] D
	CROSS JOIN Dim.[Time] T