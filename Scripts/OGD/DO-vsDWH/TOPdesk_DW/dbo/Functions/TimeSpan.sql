CREATE FUNCTION [dbo].[TimeSpan]
(
	@startdate datetime
	, @enddate datetime
	, @SupportWindowID int
)
RETURNS int
AS
BEGIN

-- Geeft tijdsverschil in seconden tussen @startdate en @enddate, binnen gegeven @SupportWindow (dus alleen tijd waarop support is telt mee) 

-- Als S1 = @T1 afgerond naar beneden (op half uur) te vinden is in SW dan is call binnen support gestart, in dat geval moet het verschil (S1 - T1) bij de doorlooptijd worden opgeteld
-- Als S2 = @T2 afgerond naar beneden (op half uur) te vinden is in SW dan is call binnen support beindigd

-- Tijden omrekenen naar integers:
DECLARE @TStart int = DATEDIFF(SS, '1970-01-01', @startdate)
DECLARE @TEnd int = DATEDIFF(SS, '1970-01-01', @enddate)

-- Afronden naar boven:
DECLARE @RStart int = CEILING(CAST(@TStart AS float) / 1800) * 1800

DECLARE @StartSupport bit
DECLARE @EndSupport bit
DECLARE @StartRN int
DECLARE @EndRN int
DECLARE @Duration int = 0

-- Check of start binnen support valt, bijbehorend rijnummer ophalen:
SELECT @StartSupport = Support, @StartRN = SupportedRN
FROM Fact.SupportWindowPerHalfHour
WHERE [TimeStamp] = (@TStart/1800) * 1800 AND SupportWindowID = @SupportWindowID

-- Support voor eind:
SELECT @EndSupport = Support
FROM Fact.SupportWindowPerHalfHour
WHERE [TimeStamp] = (@TEnd/1800) * 1800 AND SupportWindowID = @SupportWindowID

-- Voor rijnummer moeten we 1 blok eerder kijken (we kunnen niet gewoon -1 doen, want 19:00 heeft zelfde rn als 18:30, maar 07:00 de volgende dag heeft rn+1)
SELECT @EndRN = SupportedRN
FROM Fact.SupportWindowPerHalfHour
WHERE [TimeStamp] = (@TEnd/1800) * 1800 - 1800 AND SupportWindowID = @SupportWindowID

-- Eind voor start:
IF (@TStart >= @TEnd)
	SET @Duration = 0
ELSE
	-- Als start en eind in hetzelfde halfuur (EN in support) vallen dan nemen we het verschil:
	IF (@TStart / 1800) = (@TEnd / 1800)
		SET @Duration = (@TEnd - @TStart) * @StartSupport
	ELSE
	-- Start > eind, niet in hetzelfde halfuur:
	BEGIN
		-- Aantal seconden in start-halfuur:
		SET @Duration = @StartSupport * (1800 - (@TStart % 1800))

		-- Aantal seconden in eind-halfuur:
		SET @Duration += @EndSupport * (@TEnd % 1800)

		-- Alle tussenliggende halve uren:		
		SET @Duration += (@EndRN - @StartRN) * 1800
	END

RETURN @Duration

END

/*

SELECT dbo.TimeSpan ('20151202 18:59:58', '20151203 07:31:00', 1)

SELECT dbo.TimeSpan ('20151203 09:32:58', '20151203 09:33:00', 1)

SELECT 
	[Start] = CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime)
	, [End] = CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime)
	, DATEDIFF(SS, CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime), CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime))
	, dbo.TimeSpan (CAST(CreationDate AS datetime) + CAST(CreationTime AS datetime), CAST(ClosureDate AS datetime) + CAST(ClosureTime AS datetime),1001)
	, *	
FROM
	Fact.Incident
WHERE 1=1
	AND SourceDatabaseKey = 18

--****************************************************************************************************
--Testcases:
--****************************************************************************************************

SELECT dbo.TimeSpan ('20160222 13:00:00', '20160222 12:00:00', 1) -- normale werkdag, eind voor start
SELECT dbo.TimeSpan ('20160222 13:00:00', '20160222 13:00:00', 1) -- normale werkdag, 0 uur
SELECT dbo.TimeSpan ('20160222 13:00:00', '20160222 14:00:00', 1) -- normale werkdag, 1 uur
SELECT dbo.TimeSpan ('20160222 12:59:59', '20160222 13:00:01', 1) -- normale werkdag, 2 sec 
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160222 19:00:00', 1) -- normale werkdag, support t/m 19u
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160222 19:01:00', 1) -- normale werkdag, support t/m 19u
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160222 23:30:00', 1) -- normale werkdag, support t/m 19u
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160223 06:59:00', 1) -- support t/m 19u, volgende ochtend vanaf 07:00
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160223 07:00:00', 1) -- support t/m 19u, volgende ochtend vanaf 07:00
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160223 07:01:00', 1) -- support t/m 19u, volgende ochtend vanaf 07:00
SELECT dbo.TimeSpan ('20160222 18:00:00', '20160223 08:00:00', 1) -- support t/m 19u, volgende ochtend vanaf 07:00

SELECT dbo.TimeSpan ('20160220 14:00:00', '20160220 15:00:00', 1) -- weekend
SELECT dbo.TimeSpan ('20160219 18:30:00', '20160222 07:30:00', 1) -- vr-middag - ma-ochtend 

SELECT dbo.TimeSpan ('20160221 23:00:00', '20160222 08:00:00', 1) -- begin in weekend, eind in support
SELECT dbo.TimeSpan ('20160219 18:00:00', '20160220 00:30:00', 1) -- begin support, eind in weekend

SELECT dbo.TimeSpan ('20151225 14:00:00', '20151225 14:01:00', 1) -- helemaal buiten support (feestdag)
*/