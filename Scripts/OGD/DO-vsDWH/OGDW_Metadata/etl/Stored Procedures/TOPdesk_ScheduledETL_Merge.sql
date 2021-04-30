CREATE PROCEDURE [etl].[TOPdesk_ScheduledETL_Merge]
AS
BEGIN

SET NOCOUNT ON

DECLARE @dbName nvarchar(64) = '[$(OGDW)]'

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'ETL Procedure in progress...'

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

-- Haal alle definities van vrije velden op
--EXEC etl.LoadCustomColumns

-- Om tabellen leeg te maken moeten de foreign keys worden uitgeschakeld
EXEC shared.DisableForeignKeys @dbName

-- Index opnieuw vullen, anders gaan de volgende stappen veel trager:
DBCC DBREINDEX('[$(OGDW_Staging)].FileImport.Incidents') WITH NO_INFOMSGS
DBCC DBREINDEX('[$(OGDW_Staging)].FileImport.Changes') WITH NO_INFOMSGS

-- Nieuwe batches toevoegen aan OGDW_Archive:
TRUNCATE TABLE etl.GenerateBatchForArchive
EXEC etl.GenerateBatch 'FileImport', 'Incidents', 'IncidentNumber'
EXEC etl.GenerateBatch 'FileImport', 'Changes', 'ChangeNumber'
EXEC etl.ExecuteBatches

-- Dim-tabellen eerst, hier wordt naar verwezen in de fact-tabellen (zelfde sprocs als FULL)
EXEC etl.LoadDimLanguages
EXEC etl.LoadDimReportBins
EXEC etl.LoadDimReportInfo
EXEC etl.LoadDimReportLabels
EXEC etl.LoadDimColourSchema

EXEC etl.LoadDimCustomer
EXEC etl.LoadDimSLA
EXEC etl.LoadDimCallResponseSLA
EXEC etl.LoadDimUsers

--EXEC etl.LoadDimOperator
EXEC etl.LoadDimOperatorGroup
EXEC etl.LoadDimCaller
EXEC etl.LoadDimObject

EXEC etl.LoadDimIncidentTypeSTD
EXEC etl.LoadDimPrioritySTD
EXEC etl.LoadDimStatusSTD

EXEC etl.LoadDimNiceReply

/*-- Merge into fact-tables:
DECLARE @strAuditDWKeys varchar(max)

-- String met nieuwe AuditDWKeys, we nemen hiervoor de batches die afgelopen uur zijn toegevoegd aan OGDW_Staging
-- (niet helemaal netjes, maar het werkt...)
SET @strAuditDWKeys = STUFF(
	(SELECT
		',' + CAST(AuditDWKey AS varchar(8))
	FROM
		[log].[Audit]
	WHERE 1=1
		AND SourceType = 'FILE'
		AND deleted = 0
		AND DWDateCreated > DATEADD(HH,-1,GETDATE())
	ORDER BY
		AuditDWKey
	FOR XML PATH('')),1,1,'') --AS CSV

IF @strAuditDWKeys IS NOT NULL
BEGIN
	PRINT @strAuditDWKeys
--	EXEC etl.MergeFactAndDimTables @strAuditDWKeys
END
*/
EXEC etl.LoadFactSupportPerHalfHour
--EXEC etl.LoadFactSupportWindowPerHalfHour

EXEC etl.LoadFactWorkforceResourcesPerDay

EXEC etl.LoadFactIncident @delta=1
EXEC etl.LoadFactChange @delta=1
EXEC etl.LoadFactChangeActivity
EXEC etl.LoadFactProblem
EXEC etl.LoadFactCall

EXEC etl.LoadFactProbleemVermoeden
EXEC etl.LoadFactProcesFeedback

-- Schakel alle foreign keys opnieuw in
EXEC shared.EnableForeignKeys @dbName

-- Update bestaande Calls met nieuwe Customers uit MDS (calls met id -1 worden gekoppeld aan nieuwe customer)
--EXEC etl.AddExistingCallsToNewCustomer

-- Vervang lege strings en ontbrekende waarden en trek hoofdletters gelijk
EXEC etl.ReplaceEmptyStrings
EXEC etl.CorrectCasings

-- Vullen van Dim.Date en Dim.Time als ze leeg zijn
--EXEC shared.LoadDimDate @dbName
--EXEC shared.LoadDimTime @dbName

-- Sla de datum van de laatste keer dat de etl procedure is afgerond op in OGDW
EXEC ('INSERT INTO ' + @dbName + '.[log].LastLoad DEFAULT VALUES')

-- Logging
SET @newMessage = 'ETL Procedure completed...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = NULL, @RowCount = NULL

END