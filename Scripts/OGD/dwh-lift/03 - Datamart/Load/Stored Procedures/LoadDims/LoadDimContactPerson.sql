CREATE PROCEDURE [Load].[LoadDimContactPerson]
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

DELETE FROM Dim.ContactPerson

DBCC CHECKIDENT ('Dim.ContactPerson', RESEED, 140000000)

PRINT 'Inserting unknowns into Dim.ContactPerson'
SET IDENTITY_INSERT Dim.ContactPerson ON
INSERT INTO
	Dim.ContactPerson
	(
	ContactPersonKey
	, CustomerKey
	, Jobtitle
	, Department
	, Responsibility
	, Gender
	, [Role]
	)
SELECT
	ContactPersonKey = -1
	, CustomerKey = -1
	, Jobtitle = '[unknown]'
	, Department = '[unknown]'
	, Responsibility = '[unknown]'
	, Gender = '[unknown]'
	, [Role] = '[unknown]'
SET IDENTITY_INSERT Dim.ContactPerson OFF

PRINT 'Inserting data into Dim.ContactPerson'
INSERT INTO
	[Dim].[ContactPerson]
	(
	unid
	, CustomerKey
	, ContactPerson
	, Jobtitle
	, Telephone_1
	, Telephone_2
	, Mail
	, Department
	, Responsibility
	, Gender
	, LinkedIN
	, #
	, [Role]
	)
SELECT
	unid = cp.unid
	, CustomerKey = COALESCE(c.CustomerKey, -1)
	, ContactPerson = LTRIM(RTRIM(CONCAT(RTRIM(cp.rnaam), ' ', LTRIM(CONCAT(RTRIM(cp.tvoegsel), ' ', LTRIM(cp.anaam))))))
	, [Jobtitle] = cp.functie
	, Telephone_1 = cp.tel1
	, Telephone_2 = cp.tel2
	, Email = cp.email
	, Department = cp.afdeling
	, Responsibility = v.tekst
	, Gender = CASE WHEN cp.geslacht = 1 THEN 'Male' WHEN cp.geslacht = 2 THEN 'Female' ELSE NULL END
	, LinkedIN = COALESCE(cp.linkedin, cp.exveld002, '[unknown]')
	, # = ROW_NUMBER() OVER(PARTITION BY cp.klantid ORDER BY k.bedrijf)
	, [Role] = cp.rol
FROM
    [archive].contactpersoon cp
    LEFT OUTER JOIN Dim.Customer c ON c.unid = cp.klantid
    LEFT OUTER JOIN [archive].verantwoording v ON v.unid = cp.verantwoordingid
    LEFT OUTER JOIN [archive].klant k ON k.unid = cp.klantid
WHERE 1=1
	AND cp.[status] = 1 -- Active contactpersons

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