CREATE FUNCTION [dbo].[ReportStartDate]
(
	@ReportDate datetime
	, @ReportPeriod int
	, @ReportInterval nvarchar(50)
)
RETURNS datetime
AS
BEGIN

DECLARE @Return datetime
SET @ReportDate = DATEADD(DD,1,@ReportDate) -- Plus 1 dag om te zorgen dat de raport periode 1 dag opschuift zodat het incl de gekozen reportdate wordt.

SET @Return = CASE @ReportInterval
		WHEN 'month' THEN DATEADD(MM, DATEDIFF(MM, 0, DATEADD(MM, -@ReportPeriod, DATEADD(DD,-1,@ReportDate))) + 1, 0)
--		WHEN 'month' THEN DATEADD(MM, DATEDIFF(MM, 0, DATEADD(MM, -@ReportPeriod, @ReportDate)) + 1, 0) -- Geeft de eerste dag terug van de eerste volledige maand binnen de rapportperiode
		WHEN 'week' THEN DATEADD(WW, DATEDIFF(WW, 0, DATEADD(WW, -@ReportPeriod, @ReportDate-1) - 1), 7) -- Geeft de eerste dag terug van de eerste volledige week binnen de rapportperiode
		WHEN 'day' THEN DATEADD(DD, -@ReportPeriod, @ReportDate)
	END

RETURN @Return

--SELECT dbo.ReportStartDate('20141228',3,'week')

END