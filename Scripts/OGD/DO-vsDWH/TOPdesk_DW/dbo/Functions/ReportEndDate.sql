CREATE FUNCTION [dbo].[ReportEndDate]
(
	@ReportDate datetime
--	, @ReportPeriod int
--	, @ReportInterval nvarchar(50)
)
RETURNS datetime
AS
BEGIN

DECLARE @Return datetime

SET @Return = DATEADD(MI, -1, DATEADD(DD,1,CAST(@ReportDate AS smalldatetime)))

RETURN @Return

--SELECT dbo.ReportEndDate('20141228')

END