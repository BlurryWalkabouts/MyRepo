CREATE PROCEDURE [Load].[LoadFactTurnoverForecast]
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

DELETE FROM Fact.[TurnoverForecast]

PRINT 'Inserting data into Fact.TurnoverForecast'

DECLARE @ForecastStartDate AS DATETIME = (SELECT WeekStartDate FROM Dim.[Date] WHERE [Date] = CAST (GETUTCDATE() AS DATE))

;WITH 
FilteredDates AS 
(
SELECT * 
    , Workday = 1
    FROM Dim.[Date] D
    WHERE D.[Date] >= @ForecastStartDate And [DayOfWeek] < 6
)

/* Calculate Expected Additional Turnover per day */
INSERT INTO
	Fact.[TurnoverForecast]
	(
    RequestKey
    , ProjectKey
    , CustomerKey
    , NominationKey
    , LedgerKey
	, LedgerNumber
	, Ledger
    , ForecastDate
    , ProductGroup
    , Product
	, Office
	, BusinessUnit
    , ForecastType
    , TurnoverForecast
    , ValidFrom
    , ValidTo
	)

SELECT 
    RequestKey          = COALESCE(R.RequestKey, -1)
    , ProjectKey        = COALESCE(P.ProjectKey, -1)
    , CustomerKey       = COALESCE(P.CustomerKey, -1)
    , NominationKey     = -1
    , LedgerKey         = -1
	, LedgerNumber		= NULL
	, Ledger		    = NULL
    , ForecastDate      = D.[Date]
    , ProductGroup		= P.ProductGroup
    , Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
    , ForecastType      = 'Estimated Expected Additional Turnover'
    , TurnoverForecast  = CAST(R.RequestValue/SUM(D.Workday) OVER (PARTITION BY R.ProjectKey ORDER BY R.ProjectKey ASC) AS DECIMAL (12,4))
    , ValidFrom         = CAST (GETUTCDATE() AS DATETIME2)
    , ValidTo           = CAST (GETUTCDATE()+1 AS DATETIME2)
    FROM Dim.Request R
    INNER JOIN Dim.Project P    ON R.ProjectKey = P.ProjectKey
    INNER JOIN FilteredDates D  ON D.[Date] >= P.ProjectStartDate And D.[Date] <= P.ProjectEndDate
    WHERE R.RequestStatus = 1

UNION ALL
/* Calculate Maximum Additional Turnover per day */
SELECT 
    RequestKey          = COALESCE(R.RequestKey, -1)
    , ProjectKey        = COALESCE(P.ProjectKey, -1)
    , CustomerKey       = COALESCE(P.CustomerKey, -1)
    , NominationKey     = -1
    , LedgerKey         = -1
	, LedgerNumber		= NULL
	, Ledger		    = NULL
    , ForecastDate      = D.[Date]
    , ProductGroup		= P.ProductGroup
    , Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
    , ForecastType      = 'Estimated Maximum Additional Turnover'
    , TurnoverForecast  = CAST(R.RequestSalesTarget/SUM(D.Workday) OVER (PARTITION BY R.ProjectKey ORDER BY R.ProjectKey ASC) AS DECIMAL (12, 4))
    , ValidFrom         = CAST (GETUTCDATE() AS DATETIME2)
    , ValidTo           = CAST (GETUTCDATE()+1 AS DATETIME2)
    FROM Dim.Request R
    INNER JOIN Dim.Project P    ON R.ProjectKey = P.ProjectKey
    INNER JOIN FilteredDates D  ON D.[Date] >= P.ProjectStartDate AND D.[Date] <= P.ProjectEndDate
    WHERE R.RequestStatus = 1

UNION ALL
/*Calculate Turnover forecast for Projects without Nominations */
SELECT 
    RequestKey          = COALESCE(R.RequestKey, -1)
    , ProjectKey        = COALESCE(P.ProjectKey, -1)
    , CustomerKey       = COALESCE(P.CustomerKey, -1)
    , NominationKey     = -1
    , LedgerKey         = -1
	, LedgerNumber		= NULL
	, Ledger		    = NULL
    , ForecastDate      = D.[Date]
    , ProductGroup		= P.ProductGroup
    , Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
    , ForecastType      = 'Accepted Unplanned Turnover'
    , TurnoverForecast  = CAST(R.RequestSalesTarget/SUM(D.Workday) OVER (PARTITION BY R.ProjectKey ORDER BY R.ProjectKey ASC) AS DECIMAL (12,4))
    , ValidFrom         = CAST (GETUTCDATE() AS DATETIME2)
    , ValidTo           = CAST (GETUTCDATE()+1 AS DATETIME2)
    FROM Dim.Request R
    INNER JOIN Dim.Project P      ON R.ProjectKey = P.ProjectKey
    INNER JOIN FilteredDates D    ON D.[Date] >= P.ProjectStartDate AND D.[Date] <= P.ProjectEndDate
    WHERE R.RequestStatus = 2
    AND R.ProjectKey in (SELECT ProjectKey FROM Dim.Project EXCEPT SELECT ProjectKey FROM Dim.Nomination)

UNION ALL
/*Calculate the planned Turnover based on Fact.planning for Accepted projects and requests */
SELECT
    RequestKey          = -1
    , ProjectKey        = COALESCE(P.ProjectKey, -1)
    , CustomerKey       = COALESCE(P.CustomerKey, -1)
    , NominationKey     = COALESCE(Pl.NominationKey, -1)
    , LedgerKey         = COALESCE(N.LedgerKey, -1)
	, LedgerNumber		= L.[Text]
	, Ledger		    = L.[Description]
    , ForecastDate      = Pl.PlanningDate
    , ProductGroup		= P.ProductGroup
    , Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
    , ForecastType      = 'Estimated Planned Turnover'
    , TurnoverForecast  = Pl.EstimatedPlannedTurnover
    , ValidFrom         = CAST (GETUTCDATE() AS DATETIME2)
    , ValidTo           = CAST (GETUTCDATE()+1 AS DATETIME2)
    FROM Fact.Planning Pl
    INNER JOIN Dim.Nomination N   ON Pl.NominationKey = N.NominationKey
    INNER JOIN Dim.Ledger L       ON N.LedgerKey =  L.LedgerKey
    INNER JOIN Dim.Project P      ON N.ProjectKey = P.ProjectKey
    WHERE PlanningDate >= @ForecastStartDate
    AND ABS(N.[Status]) = 2

UNION ALL
/*Calculate the planned Turnover based on open requests */
SELECT
    RequestKey          = -1
    , ProjectKey        = COALESCE(P.ProjectKey, -1)
    , CustomerKey       = COALESCE(P.CustomerKey, -1)
    , NominationKey     =  COALESCE(Pl.NominationKey, -1)
    , LedgerKey         = COALESCE(N.LedgerKey, -1)
	, LedgerNumber		= L.[Text]
	, Ledger		    = L.[Description]
    , ForecastDate      = Pl.PlanningDate
    , ProductGroup		= P.ProductGroup
    , Product		    = P.Product
	, Office		    = P.Office
	, BusinessUnit      = CASE
							WHEN P.ProductGroup like 'BUO%' THEN 'Outsourcing'
							ELSE P.ProductGroup
						  END
    , ForecastType      = 'Estimated Planned Additional Turnover'
    , TurnoverForecast  = Pl.EstimatedPlannedTurnover
    , ValidFrom         = CAST (GETUTCDATE() AS DATETIME2)
    , ValidTo           = CAST (GETUTCDATE()+1 AS DATETIME2)
    FROM Fact.Planning Pl
    INNER JOIN Dim.Nomination N   ON Pl.NominationKey = N.NominationKey
    INNER JOIN Dim.Ledger L       ON N.LedgerKey =  L.LedgerKey
    INNER JOIN Dim.Project P      ON N.ProjectKey = P.ProjectKey
    WHERE 1=1
    AND N.[Status] = 1
    AND PlanningDate >= @ForecastStartDate

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