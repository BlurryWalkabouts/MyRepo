CREATE PROCEDURE [etl].[LoadFactChangeActivity]
AS
BEGIN

--***************************************************************************************************************************
--Fact-ChangeActivity:
--***************************************************************************************************************************

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM [$(OGDW)].Fact.ChangeActivity
DBCC CHECKIDENT ('[$(OGDW)].Fact.ChangeActivity', RESEED, 0)

INSERT INTO
	[$(OGDW)].Fact.ChangeActivity
	(
	SourceDatabaseKey
	, AuditDWKey
	, ChangeKey
	, CustomerKey
	, OperatorGroupKey
	, OperatorKey
	, ChangeDate
	, ChangeTime
	, Approved
	, ApprovedDate
	, ApprovedTime
	, BriefDescription
	, CurrentPlanTimeTaken
	, CreationDate
	, CreationTime
	, ActivityNumber
	, OriginalPlanTimeTaken
	, ChangePhase
	, PlannedFinalDate
	, PlannedFinalTime
	, PlannedStartDate
	, PlannedStartTime
	, Rejected
	, RejectedDate
	, RejectedTime
	, Resolved
	, ResolvedDate
	, ResolvedTime
	, Skipped
	, SkippedDate
	, SkippedTime
	, Closed
	, ClosureDate
	, ClosureTime
	, [Started]
	, StartedDate
	, StartedTime
	, TimeTaken
	, MayStart
	, ChangeBriefDescription
	, ActivityTemplate
	, Category
	, ActivityChange
	, Subcategory
	, CardCreatedBy
	, CardChangedBy
	, [Status]
	, ProcessingStatus
	, MaxPreviousActivityEndDate
	, ChangePhaseStartDate
	, [Level]
	, PlannedStartRank
	)
SELECT
	AC.SourceDatabaseKey
	, AC.AuditDWKey

	, ChangeKey = ISNULL(CH.Change_Id,-1)
	-- Voor Multi-klant topdesk in de FileImport staat de Customer in de kolom [CustomerName], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Multi-klant topdesk in de database staat de Customer in [vestiging].[naam], deze staat in CH.CustomerName in het Anchormodel
	-- Voor Single-klant topdesk in de FileImport is de kolom [CustomerName] = NULL en wordt de naam dus opgehaald via SourceDefinition
	-- Voor Single-klant topdesk in de database bevat de kolom [vestiging].[naam] daadwerkelijk de vestiging; halen we de Customer dus op via SourceDefinition
	-- Via onderstaande regel zou altijd een CustomerKey gevonden moeten worden, tenzij er geen vertaling gedefinieerd is
	, CustomerKey = ISNULL(CAST(CASE
			WHEN SD.MultipleCustomers = 0 THEN C1.Code -- Klantnaam via SourceDefinition
			ELSE ISNULL(CH.CustomerKey,-1) -- Klantnaam van bijbehorende change
		END AS int),-1) -- Bij gegevens uit de database moet deze key op een andere manier worden bepaald
	, OperatorGroupKey = ISNULL(AC.OperatorGroupKey,-1)
	, OperatorKey = ISNULL(AC.OperatorKey,-1)

	, AC.ChangeDate
	, AC.ChangeTime
	, AC.Approved
	, AC.ApprovedDate
	, AC.ApprovedTime
	, AC.BriefDescription
	, AC.CurrentPlanTimeTaken
	, AC.CreationDate
	, AC.CreationTime
	, AC.ActivityNumber
	, AC.OriginalPlanTimeTaken
	, AC.ChangePhase
	, AC.PlannedFinalDate
	, AC.PlannedFinalTime
	, AC.PlannedStartDate
	, AC.PlannedStartTime
	, AC.Rejected
	, AC.RejectedDate
	, AC.RejectedTime
	, AC.Resolved
	, AC.ResolvedDate
	, AC.ResolvedTime
	, AC.Skipped
	, AC.SkippedDate
	, AC.SkippedTime
	, Closed = COALESCE(AC.Rejected, AC.Resolved, AC.Skipped)
	, ClosureDate = COALESCE(AC.RejectedDate, AC.ResolvedDate, AC.SkippedDate)
	, ClosureTime = COALESCE(AC.RejectedTime, AC.ResolvedTime, AC.SkippedTime)
	, AC.[Started]
	, AC.StartedDate
	, AC.StartedTime
	, AC.TimeTaken
	, AC.MayStart
	, AC.ChangeBriefDescription
	, AC.ActivityTemplate
	, AC.Category
	, AC.ActivityChange
	, AC.Subcategory
	, AC.CardCreatedBy
	, AC.CardChangedBy
	, AC.[Status]
	, AC.ProcessingStatus

	, AC.MaxPreviousActivityEndDate
	, AC.ChangePhaseStartDate
	, AC.[Level]
	, AC.PlannedStartRank

FROM
	etl.Translated_ChangeActivity AC
	LEFT OUTER JOIN setup.SourceDefinition SD ON AC.SourceDatabaseKey = SD.Code
	LEFT OUTER JOIN setup.DimCustomer C1 ON SD.DatabaseLabel = C1.[Name]
	-- Er zit geen [CustomerName] in ChangeActivity, waar halen we deze dan vandaan? (voor multi-klant-databases)
-- LEFT OUTER JOIN setup.SourceTranslation ST ON AC.CustomerName = ST.SourceValue AND SD.DatabaseLabel = ST.SourceName
--		AND ST.DWColumnNam = 'CustomerName' AND TranslatedColumnName = 'CustomerAbbreviation'
--	LEFT OUTER JOIN setup.DimCustomer C2 on ST.TranslatedValue = C2.[Name]

	-- We kijken naar ChangeNumber om ChangeKey en CustomerKey te bepalen:
	LEFT OUTER JOIN [$(OGDW)].Fact.Change CH ON AC.ActivityChange = CH.ChangeNumber AND AC.SourceDatabaseKey = CH.SourceDatabaseKey
	OPTION (MAXRECURSION 0)

SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END