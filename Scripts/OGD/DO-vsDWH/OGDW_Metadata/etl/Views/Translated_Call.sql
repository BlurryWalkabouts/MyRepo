CREATE VIEW [etl].[Translated_Call]
AS
SELECT
	CallSummaryID = CS.id -- Eigenlijk is dit CallSummaryID...
--	, CustomerKey = ISNULL(CU.CustomerKey, -1)
	, StartDateKey = CAST(REPLACE(CAST(CONVERT(varchar,starttime,112) AS int),17530101,-1) AS int)
	, StartTimeKey = CASE WHEN CAST(CONVERT(varchar,starttime,112) AS int) = 17530101 THEN -1 ELSE DATEDIFF(SS,0,CAST(starttime AS time)) END
	, InQueueDateKey = CAST(REPLACE(CAST(CONVERT(varchar,inqueuetime,112) AS int),17530101,-1) AS int)
	, InQueueTimeKey = CASE WHEN CAST(CONVERT(varchar,inqueuetime,112) AS int) = 17530101 THEN -1 ELSE DATEDIFF(SS,0,CAST(inqueuetime AS time)) END
--	, QueueTime = CAST(inqueuetime AS time(0))
	, AcceptedDateKey = CAST(REPLACE(CAST(CONVERT(varchar,acceptedtime,112) AS int),17530101,-1) AS int)
	, AcceptedTimeKey = CASE WHEN CAST(CONVERT(varchar,acceptedtime,112) AS int) = 17530101 THEN -1 ELSE DATEDIFF(SS,0,CAST(acceptedtime AS time)) END
--	, AcceptedTime = CAST(acceptedtime AS time(0))
	, EndDateKey = CAST(REPLACE(CAST(CONVERT(varchar,endtime,112) AS int),17530101,-1) AS int)
	, EndTimeKey = CASE WHEN CAST(CONVERT(varchar,endtime,112) AS int) = 17530101 THEN -1 ELSE DATEDIFF(SS,0,CAST(endtime AS time)) END
--	, EndTime = CAST(endtime AS time(0))
	, UCCName = CN.[name]
	, [Caller] = C.[caller]
	, StartTime = CS.starttime
	, InQueueTime = CS.inqueuetime
	, AcceptedTime = CS.acceptedtime
	, EndTime = CS.endtime
	, Accepted = CS.accepted
	, CallDuration = CASE WHEN CS.accepted = 1 THEN DATEDIFF(SS,CS.acceptedtime,CS.endtime) ELSE 0 END
	, CallTotalDuration = DATEDIFF(SS,CS.starttime,CS.endtime)
	, QueueDuration = CAST(CS.queuetime AS int) -- Onderscheid tussen time en duration...
	, SkillChosen = CS.skillChosen
	, InitialAgent = CS.initialAgent
	, Handled = CS.handled
	, DWDateCreated = CS.DWDateCreated
--	, ucc_id
FROM
	[$(OGDW_Staging)].Anywhere365_UCC.UCC_CallSummary CS
	INNER JOIN [$(OGDW_Staging)].Anywhere365_UCC.UCC_Call C ON CS.correlationid = C.correlationid
	INNER JOIN [$(OGDW_Staging)].Anywhere365_UCC.UCC_Name CN ON C.ucc_id = CN.id
WHERE 1=1
	AND CS.skillChosen NOT LIKE 'FORWARD %'
/*
Om de juist klant te vinden moeten we nog zoiets als dit doen:

SELECT
	*
FROM
	Fact.Call Ca
WHERE 1=1
	AND Accepted = 0
ORDER BY
	CallTotalDuration

JOIN [$(MDS)].mdm.AnywhereSkillTranslation A ON A.[Name] = CA.skillChosen
JOIN dim.Customer C ON C.CustomerKey = A.Customer_Code
JOIN dim.Date D ON CAST(Ca.acceptedtime AS date) = D.Date

DECLARE @s INT = 325
DECLARE @t time

--conversie van secondes naar time:
SELECT @t = CONVERT(TIME, DATEADD(SECOND, @s, 0));
SELECT @t

--van time naar secondes:
SELECT DATEDIFF(SS,0,@t)

*/