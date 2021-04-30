CREATE PROCEDURE [etl].[LoadDimCustomer]
AS
BEGIN

-- ================================================
-- Create dim table for Customer.
-- This is a straight copy from MDS.
-- ================================================

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

DELETE FROM [$(OGDW)].Dim.Customer

INSERT INTO
	[$(OGDW)].Dim.Customer
	(
	CustomerKey
	, DebitNumber
	, Fullname
	, CustomerSector
	, CustomerGroup
	, SLA
	, EndUserServiceType
	, SysAdminServiceType
	, SysAdminTeam
	, OutsourcingType
	, ServicesType
	, ExpIncLoad
	, ExpChaLoad
	, ExpCallLoad
	, SupportWeekend
	, RequiredSecurityClearance
	, Postcode
	, SupportWindow
	, SupportWindow_ID
	, TelephoneNumber
	, AantalGebruikers
	, AantalWerkplekken
	, Piketdienst
	, Archived
	, OnBoardDate
	, OffBoardDate
	, ValidFrom
	, ValidTo
	)
SELECT
	CustomerKey = CAST(Code AS int)
	, DebitNumber
	, Fullname
	, CustomerSector = CustomerSector_Name
	, CustomerGroup = CustomerGroup_Name
	, SLA = SLA_Name
	, EndUserServiceType = EndUserServiceType_Name
	, SysAdminServiceType = SysAdminServiceType_Name
	, SysAdminTeam = SysAdminTeam_Name
	, OutsourcingType = OutsourcingType_Name
	, ServicesType = ServicesType_Name
	, ExpIncLoad
	, ExpChaLoad
	, ExpCallLoad
	, SupportWeekend
	, RequiredSecurityClearance = RequiredSecurityClearance_Name
	, Postcode
	, SupportWindow = SupportWindow_Name
	, SupportWindow_ID
	, TelephoneNumber
	, AantalGebruikers
	, AantalWerkplekken
	, Piketdienst
	, Archived
	, OnBoardDate
	, OffBoardDate
	, ValidFrom
	, ValidTo
--	, CustomerKey --nieuwe kolom, moet nog verwerkt worden (vanwege SCD, ander ticket)
FROM
	[$(MDS)].mdm.DimCustomer

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