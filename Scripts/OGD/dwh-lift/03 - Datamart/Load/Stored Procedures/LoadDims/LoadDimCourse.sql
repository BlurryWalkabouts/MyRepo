CREATE PROCEDURE [Load].[LoadDimCourse]
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

DELETE FROM Dim.Course

DBCC CHECKIDENT ('Dim.Course', RESEED, 80000000)

PRINT 'Inserting unknowns into Dim.Course'
SET IDENTITY_INSERT Dim.Course ON
INSERT INTO
	Dim.Course
	(
	CourseKey
	, EmployeeKey
	, [Provider]
	, CourseName
	, CourseDate
	, CourseEndDate
	, CourseDuration
	, DiplomaObtained
	)
SELECT
	CourseKey = -1
	, EmployeeKey = -1
	, [Provider] = '[unknown]'
	, CourseName = '[unknown]'
	, CourseDate = '99991231'
	, CourseEndDate = '99991231'
	, CourseDuration = -1
	, DiplomaObtained = 0
SET IDENTITY_INSERT Dim.Course OFF

PRINT 'Inserting data into Dim.Course'
INSERT INTO
	Dim.Course
	(
	unid
	, EmployeeKey
	, [Provider]
	, CourseName
	, CourseDate
	, CourseEndDate
	, CourseDuration
	, DiplomaObtained
	)
SELECT
	unid = c.unid
	, EmployeeKey = COALESCE(e.EmployeeKey, -1)
	, [Provider] = c.leverancier
	, CourseName = c.naam
	, CourseDate = c.cursusdatum
	, CourseEndDate = c.einddatum
	, CourseDuration = c.dagen
	, DiplomaObtained = c.diploma
FROM
    [archive].cursus c
	LEFT OUTER JOIN Dim.Employee e ON e.unid = c.werknemerid

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