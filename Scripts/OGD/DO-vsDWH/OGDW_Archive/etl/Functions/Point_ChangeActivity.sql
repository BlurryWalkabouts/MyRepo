-- Point-in-time perspective ------------------------------------------------------------------------------------------
-- Point_ChangeActivity viewed as it was ON the given timepoint
-----------------------------------------------------------------------------------------------------------------------
CREATE FUNCTION [etl].[Point_ChangeActivity]
(
	@changingTimepoint datetime2(0)
)
RETURNS TABLE
AS
RETURN
/*

-- Constructie 1 zou iets sneller moeten zijn (voor 71.953 rijen in changeactivity__dependency), maar is niet toepasbaar in een (multi-statement) tvf
-- While loop: ~12 seconden, ~125.000 logical reads
-- Recursie: ~25 seconden, ~2.5 miljoen logical reads

-- Contructie 1

DROP TABLE IF EXISTS #ca_prev

SELECT
	cad.SourceDatabaseKey
	, cad.headid
	, cad.tailid
	, PreviousActivityEndDate = COALESCE(ca_prev.rejecteddate, ca_prev.resolveddate, ca_prev.skippeddate)
	, [Level] = 1
INTO
	#ca_prev
FROM
	TOPdesk.changeactivity__dependency FOR SYSTEM_TIME AS OF @changingTimepoint cad
	LEFT OUTER JOIN TOPdesk.changeactivity FOR SYSTEM_TIME AS OF @changingTimepoint ca_prev ON cad.headid = ca_prev.unid AND cad.SourceDatabaseKey = ca_prev.SourceDatabaseKey

-- Levels invullen, zonder gebruik van recursie (zie alternatieve code halverwege)
-- Activiteiten met afhankelijkheden krijgen het level van de vorige + 1

DECLARE @i int = 0

WHILE @i < 12 -- Meer dan twaalf levels diep komt niet voor en we gaan er ook vanuit dat er geen cirkels voorkomen (want dit zou voor een changeactivity-deadlock zorgen)
BEGIN
	UPDATE
		X
	SET
		[Level] = Y.[Level] + 1
	FROM
		#ca_prev X
		LEFT OUTER JOIN #ca_prev Y ON X.headid = Y.tailid AND X.tailid <> Y.headid
		-- Hiermee voorkomen we hele kleine cirkeltjes (deze komen voor). In theorie kan er nog steeds in meerdere stappen een cirkel gemaakt worden, maar deze zijn er nog niet
	WHERE 1=1
		AND X.[Level] <> Y.[Level] + 1

	-- Herhalen tot maximum diepte:
	SET @i +=1
END

-- Nu nog groeperen op unid van de wijziginsactiviteit (tailid)
-- Hierbij nemen we MAX(Level), want het kan voorkomen dat een activiteit op verschillende andere activiteiten wacht en dan is zijn level dus het hoogste level + 1

;WITH changeactivity__dependency AS
(
SELECT
	SourceDatabaseKey
	, tailid
	, MaxPreviousActivityEndDate = MAX(PreviousActivityEndDate)
	, [Level] = MAX([Level])
FROM
	#ca_prev
GROUP BY
	SourceDatabaseKey
	, tailid
)
*/

-- Constructie 2

WITH ca_prev_step1 AS
(
SELECT
	cad.SourceDatabaseKey
	, cad.headid
	, cad.tailid
	, PreviousActivityEndDate = COALESCE(ca_prev.rejecteddate, ca_prev.resolveddate, ca_prev.skippeddate)
FROM
	TOPdesk.changeactivity__dependency FOR SYSTEM_TIME AS OF @changingTimepoint cad
	LEFT OUTER JOIN TOPdesk.changeactivity FOR SYSTEM_TIME AS OF @changingTimepoint ca_prev ON cad.headid = ca_prev.unid AND cad.SourceDatabaseKey = ca_prev.SourceDatabaseKey
WHERE 1=1
	-- Er zijn changeactivity__dependencies bij SDK 347 (PG) dd 30-08-2018 waarvan de bijbehorende activiteiten ontbreken. Zitten op zich niet in de weg, maar actief
	-- weggefilterd om het inzichtelijk te maken.
	AND ca_prev.changeid IS NOT NULL
	-- MINT18081013 - Zie OGDW_Metadata.monitoring.LoadCircularReferences
	AND NOT EXISTS (SELECT 1 FROM monitoring.CircularReferences cr WHERE cad.SourceDatabaseKey = cr.SourceDatabaseKey AND ca_prev.changeid = cr.changeid)
)

, ca_prev_step2 AS
(
SELECT 
	SourceDatabaseKey, 
	tailid, 
	headid, 
	PreviousActivityEndDate, 
	[Level] = 1
FROM ca_prev_step1 X1
UNION ALL
SELECT 
	X2.SourceDatabaseKey, 
	X2.tailid, 
	X2.headid, 
	X2.PreviousActivityEndDate, 
	[Level] = [Level] + 1
FROM ca_prev_step1 X2
INNER JOIN ca_prev_step2 Y ON Y.SourceDatabaseKey = X2.SourceDatabaseKey AND Y.tailid = X2.headid 
WHERE [Level] < 99
)

, changeactivity__dependency AS
(
SELECT
	SourceDatabaseKey
	, tailid
	, MaxPreviousActivityEndDate = MAX(PreviousActivityEndDate)
	, [Level] = MAX([Level])
FROM
	ca_prev_step2
GROUP BY
	SourceDatabaseKey
	, tailid
)

SELECT
	SourceDatabaseKey = ca.SourceDatabaseKey
	, AuditDWKey = ca.AuditDWKey

	, OperatorGroupID = ca.operatorgroupid
	, OperatorGroup = a2.ref_dynanaam
	, OperatorID = ca.operatorid
	, OperatorName = a1.ref_dynanaam

	, ActivityNumber = ca.number
	, BriefDescription = ca.briefdescription
	, Category = c1.naam
	, Subcategory = c2.naam
	, [Status] = cs.naam
	, ProcessingStatus = NULL
	, ActivityTemplate = ct.number

	, ActivityChange = ch.number
	, ChangeBriefDescription = ca.ref_change_brief_description
	, ChangePhase = ca.changephase

	, CardCreatedBy = g1.naam
	, CreationDate = ca.dataanmk
	, CardChangedBy = g2.naam
	, ChangeDate = ca.datwijzig

	, MayStart = ca.maystart
	, PlannedStartDate = ca.plannedstartdate
	, PlannedFinalDate = ca.plannedfinaldate
	, Approved = ca.approved
	, ApprovedDate = ca.approveddate
	, Rejected = ca.rejected
	, RejectedDate = ca.rejecteddate
	, [Started] = ca.[started]
	, StartedDate = ca.starteddate
	, Resolved = ca.resolved
	, ResolvedDate = ca.resolveddate
	, Skipped = ca.skipped
	, SkippedDate = ca.skippeddate

	, CurrentPlanTimeTaken = ca.currentplantimetaken
	, OriginalPlanTimeTaken = ca.originalplantimetaken
	, TimeTaken = ca.timetaken

	, MaxPreviousActivityEndDate = cd.MaxPreviousActivityEndDate
	-- Als er überhaupt geen voorafgaande wijziginsactiviteit is dan kijken we naar de fase
	, ChangePhaseStartDate = CASE ca.changephase
			WHEN 2 THEN ch.calldate	-- Aanvraagfase kan starten als call ingeschoten is
			WHEN 5 THEN ch.authorizationdate -- Implementatie/uitvoer kan starten als autorisatie binnen is
			WHEN 6 THEN ch.implementationdate -- Evaluatiefase start na implementatie
		END
	, [Level] = COALESCE(cd.[Level],0)
	, PlannedStartRank = CAST(RANK() OVER (PARTITION BY ch.SourceDatabaseKey, ch.number ORDER BY ca.plannedstartdate) AS int)
FROM
	TOPdesk.changeactivity FOR SYSTEM_TIME AS OF @changingTimepoint ca
	LEFT OUTER JOIN TOPdesk.change                  FOR SYSTEM_TIME AS OF @changingTimepoint ch ON ch.unid = ca.changeid           AND ch.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.change_activitytemplate FOR SYSTEM_TIME AS OF @changingTimepoint ct ON ct.unid = ca.activitytemplateid AND ct.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker               FOR SYSTEM_TIME AS OF @changingTimepoint g2 ON g2.unid = ca.uidwijzig          AND g2.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.gebruiker               FOR SYSTEM_TIME AS OF @changingTimepoint g1 ON g1.unid = ca.uidaanmk           AND g1.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie           FOR SYSTEM_TIME AS OF @changingTimepoint c1 ON c1.unid = ca.categoryid         AND c1.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor               FOR SYSTEM_TIME AS OF @changingTimepoint a1 ON a1.unid = ca.operatorid         AND a1.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.actiedoor               FOR SYSTEM_TIME AS OF @changingTimepoint a2 ON a2.unid = ca.operatorgroupid    AND a2.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.changeactivity_status   FOR SYSTEM_TIME AS OF @changingTimepoint cs ON cs.unid = ca.activitystatusid   AND cs.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN TOPdesk.classificatie           FOR SYSTEM_TIME AS OF @changingTimepoint c2 ON c2.unid = ca.subcategoryid      AND c2.SourceDatabaseKey = ca.SourceDatabaseKey
	LEFT OUTER JOIN         changeactivity__dependency                                       cd ON ca.unid = cd.tailid             AND cd.SourceDatabaseKey = ca.SourceDatabaseKey