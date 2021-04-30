CREATE PROCEDURE [Monitoring].[CheckFailedSprocs]
(
	@period int = 24
)
AS

BEGIN

SELECT *
FROM Monitoring.FailedSprocs
WHERE StartDate >= DATEADD(HH,-@period,GETDATE())

END