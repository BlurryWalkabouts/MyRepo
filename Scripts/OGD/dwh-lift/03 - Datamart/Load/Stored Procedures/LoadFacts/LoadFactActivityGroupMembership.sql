CREATE PROCEDURE [Load].[LoadFactActivityGroupMembership]
(
	@WriteLog bit = 1
)
AS
BEGIN

SET NOCOUNT ON

BEGIN TRY

-- Declare variables for logging
DECLARE @newLogID int
DECLARE @newSessionID int = @@SPID
DECLARE @newObjectID int = @@PROCID
DECLARE @newMessage nvarchar(max) = 'Loading in progress...'
DECLARE @newRowCount int = 0

-- Start logging
IF @WriteLog = 1
	EXEC [Log].NewProcLogRecord @LogID = @newLogID OUTPUT, @SessionID = @newSessionID, @ObjectID = @newObjectID, @Message = @newMessage

BEGIN TRANSACTION

DELETE FROM Fact.ActivityGroupMembership

PRINT 'Inserting data into Fact.ActivityGroupMembership'
INSERT INTO
	Fact.ActivityGroupMembership
	(        				
	 EmployeeKey
	, ActivityGroupKey	
	, unid
	)
SELECT	
	 EmployeeKey = COALESCE(e.EmployeeKey, -1) -- Always matches, except for 181 cases (employeeid in source table is NULL in 181 cases)
	, ActivityGroupKey = COALESCE(ag.ActivityGroupKey, -1)
	, unid = wagl.unid
FROM
	[archive].werknemer_activiteitgroep_link wagl
	LEFT OUTER JOIN Dim.Employee e ON wagl.werknemerid = e.unid
	LEFT OUTER JOIN Dim.ActivityGroup ag ON wagl.activiteitgroepid = ag.unid
	
SET @newRowCount += @@ROWCOUNT
COMMIT TRANSACTION

-- Logging of success
SET @newMessage = 'Loading successful...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage, @Success = 1, @RowCount = @newRowCount

END TRY

BEGIN CATCH
ROLLBACK TRANSACTION

PRINT ERROR_MESSAGE()

-- Logging of failure
SET @newMessage = 'Loading FAILED...'
IF @WriteLog = 1
	EXEC [Log].UpdateProcLogRecord @LogID = @newLogID, @Message = @newMessage

END CATCH

END