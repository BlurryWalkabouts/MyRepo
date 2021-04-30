CREATE PROCEDURE [etl].[TOPdesk_ScheduledETL_Full]
AS
BEGIN

SET NOCOUNT ON
/*20-9-2018: Entire sproc disabled. Sproc is obsolete.

DECLARE @dbName nvarchar(64) = '[$(OGDW)]'

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'ETL Procedure in progress...'

-- Start logging
EXEC [log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

-- Haal alle definities van vrije velden op
EXEC etl.LoadCustomColumns
-- Detecteer circulaire referenties tussen wijzigingsactiviteiten
EXEC monitoring.LoadCircularReferences

-- Om tabellen leeg te maken moeten de foreign keys worden uitgeschakeld
EXEC shared.DisableForeignKeys @dbName
	
-- Dit lost het probleem met trage views op, zonder deze rebuild duurt de staging uren
-- Maar dit zou anders moeten kunnen, het bestaande deel van de stagingtabellen veranderd helemaal niet en het nieuwe deel 
-- wordt per AuditDWKey ingeladen, dus de index zou gewoon goed moeten blijven...?
--EXEC etl.RebuildStagingIndexes
--EXEC etl.LoadStagingIntoAM

-- Maak alle fact- en dim-tabellen opnieuw aan (dit is sowieso nodig bij gewijzigde vertalingen / aanpassingen in de kolommen van de fact-tables),
-- Voor het snel toevoegen van een batch is er een Merge-procedure

-- Dim-tabellen eerst, hier wordt naar verwezen in de fact-tabellen
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

EXEC etl.LoadFactSupportPerHalfHour
--EXEC etl.LoadFactSupportWindowPerHalfHour

EXEC etl.LoadFactWorkforceResourcesPerDay

EXEC etl.LoadFactIncident
EXEC etl.LoadFactChange
EXEC etl.LoadFactChangeActivity
EXEC etl.LoadFactProblem
EXEC etl.LoadFactCall
EXEC etl.LoadFactOperationalActivity

EXEC etl.LoadFactProbleemVermoeden
EXEC etl.LoadFactProcesFeedback

-- Schakel alle foreign keys opnieuw in
EXEC shared.EnableForeignKeys @dbName

-- Update bestaande Calls met nieuwe Customers uit MDS (calls met id -1 worden gekoppeld aan nieuwe customer)
EXEC etl.AddExistingCallsToNewCustomer

-- Vervang lege strings en ontbrekende waarden en trek hoofdletters gelijk
EXEC etl.ReplaceEmptyStrings
EXEC etl.CorrectCasings

-- Vullen van Dim.Date en Dim.Time als ze leeg zijn
EXEC shared.LoadDimDate @dbName
EXEC shared.LoadDimTime @dbName

EXEC shared.LoadRolePermissions @dbName
EXEC shared.AssignRolePermissions @dbName

-- Sla de datum van de laatste keer dat de etl procedure is afgerond op in OGDW
EXEC ('INSERT INTO ' + @dbName + '.[log].LastLoad DEFAULT VALUES')

-- Logging
SET @newMessage = 'ETL Procedure completed...'
EXEC [log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = NULL, @RowCount = NULL
*/
END