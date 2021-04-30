CREATE PROCEDURE [Load].[LoadLiftDW]
WITH EXECUTE AS OWNER
AS

BEGIN

/********************************************************************************

********************************************************************************/

PRINT 'Run pre-load procedure...'
EXEC [Load].PreLoadDatamart

/********************************************************************************
Insert data into Dim and Fact tables
********************************************************************************/

PRINT 'Load Dim Tables...'
EXEC [Load].LoadDimAccountManager
EXEC [Load].LoadDimHourType
EXEC [Load].LoadDimService
EXEC [Load].LoadDimCustomer
EXEC [Load].LoadDimEmployee
EXEC [Load].LoadDimLedger
EXEC [Load].LoadDimProject
EXEC [Load].LoadDimContactPerson
EXEC [Load].LoadDimTask
EXEC [Load].LoadDimRequest
EXEC [Load].LoadDimActivityGroup
EXEC [Load].LoadDimNomination
EXEC [Load].LoadDimCourse
EXEC [Load].LoadDimDiploma
EXEC [Load].LoadDimInvoice


PRINT 'Load Fact Tables...'
EXEC [Load].LoadFactHour
EXEC [Load].LoadFactAppointment
EXEC [Load].LoadFactEmployeeDiploma
EXEC [Load].LoadFactEmployeeContract;
EXEC [Load].LoadFactPlanning
--EXEC [Load].LoadFactPlanningHistory --TODO procedure needs fixing
EXEC [Load].LoadFactActivityGroupMembership
EXEC [Load].LoadFactSickLeave
EXEC [Load].LoadFactTurnover
EXEC [Load].LoadFactTurnoverForecast
EXEC [Load].LoadFactCertificatePerBusinessUnit
EXEC [Load].LoadFactContactNote
EXEC [Load].LoadFactInvoiceDetail

/********************************************************************************

********************************************************************************/

PRINT 'Run post-load procedure...'
EXEC [Load].PostLoadDatamart

END
