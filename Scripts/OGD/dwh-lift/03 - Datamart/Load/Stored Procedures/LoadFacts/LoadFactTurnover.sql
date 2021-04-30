CREATE PROCEDURE [Load].[LoadFactTurnover]
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

DELETE FROM Fact.[Turnover]

PRINT 'Inserting data into Fact.Turnover'

INSERT INTO
	Fact.[Turnover]
	(
	RequestKey
	, ProjectKey
	, CustomerKey
	, NominationKey
	, LedgerKey
	, LedgerNumber
	, Ledger
	, [Date]
	, ProductGroup
	, Product
	, Office
	, BusinessUnit
	, EmpCount
	, HoursWritten
	, AvgHoursWritten
	, Turnover
	, AvgTurnover
	)

SELECT
	RequestKey		    = COALESCE(R.RequestKey, -1)
	, ProjectKey	    = COALESCE(P.ProjectKey, -1)
	, CustomerKey		= COALESCE(C.CustomerKey, -1)
	, NominationKey		= COALESCE(N.NominationKey, -1)
	, LedgerKey			= COALESCE(L.LedgerKey, -1)
	, LedgerNumber		= L.[Text]
	, Ledger		    = L.[Description]
	, [Date]		    = H.[Day]
	, ProductGroup		= P.ProductGroup
	, Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
	, EmpCount        = COUNT(DISTINCT H.EmployeeKey)
	, HoursWritten    = COALESCE(SUM(H.[Hours]*(H.[Percentage]/100.0)),0)
    , AvgHoursWritten = COALESCE(AVG(H.[Hours]*(H.[Percentage]/100.0)),0)
    , Turnover        = COALESCE(SUM(H.Turnover*H.Billable),0)
    , AvgTurnover     = COALESCE(AVG(H.Turnover*H.Billable),0)

FROM
	Fact.[Hour] AS H
	LEFT OUTER JOIN Dim.[Service]   AS S ON H.ServiceKey	= S.ServiceKey
	LEFT OUTER JOIN Dim.Task        AS T ON H.TaskKey		= T.TaskKey
	LEFT OUTER JOIN Dim.Project		AS P ON H.ProjectKey	= P.ProjectKey
	LEFT OUTER JOIN Dim.Customer    AS C ON H.CustomerKey	= C.CustomerKey
	LEFT OUTER JOIN Dim.Ledger      AS L ON H.LedgerKey	    = L.LedgerKey
	LEFT OUTER JOIN Dim.Nomination	AS N ON H.NominationKey	= N.NominationKey
	LEFT OUTER JOIN Dim.Request		AS R ON R.RequestKey	= N.RequestKey
WHERE
    H.[Day] >= '2017-01-01'
GROUP BY
	R.RequestKey
	, P.ProjectKey
	, C.CustomerKey
	, N.NominationKey
	, L.LedgerKey
	, L.[Text]
	, L.[Description]
	, P.ProductGroup
	, P.Product
	, P.Office
	, CASE
		WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
		ELSE P.ProductGroup
	  END
	, H.[Day]

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