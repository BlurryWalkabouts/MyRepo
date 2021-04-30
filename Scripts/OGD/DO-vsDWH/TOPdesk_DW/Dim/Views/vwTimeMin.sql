CREATE VIEW [Dim].[vwTimeMin]
AS

SELECT
	*
FROM
	Dim.[Time]
WHERE 1=1
	AND DATEPART(SS, [Time]) = 0