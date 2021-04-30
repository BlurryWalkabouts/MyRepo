CREATE PROCEDURE [Monitoring].[CheckDisabledForeignKeys]
(
	@period int = 24
)
AS

BEGIN

SELECT
	DisableDate
	, ForeignKey
FROM
	[Load].ForeignKeys
WHERE 1=1
	AND DisableDate BETWEEN DATEADD(HH,-@period-1,GETDATE()) AND DATEADD(HH,-1,GETDATE())

END