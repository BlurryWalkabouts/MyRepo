CREATE PROCEDURE [Load].[LoadFactSickLeave]
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

DELETE FROM Fact.SickLeave

PRINT 'Inserting data into Fact.SickLeave'
INSERT INTO
	Fact.SickLeave
	(        				
	 BusinessUnit
	 , [Function]    
	 , LedgerNumber
	 , Ledger 
	 , Office       
	 , ProductGroup
	 , UurtypeSTD     
	 , DWMonthNumber
	 , EmpCount   
	 , HoursWritten
	)
SELECT
     [BusinessUnit] = COALESCE(E.[BusinessUnit], 'Onbekend')
     , [Function] = COALESCE(E.[Function], 'Onbekend')     
     , [LedgerNumber] = L.[Text]     
     , [Ledger] = L.[Description]     
     , P.[Office]     
     , P.[ProductGroup]
     , [UurtypeSTD] =     
     CASE     
          WHEN HT.[RateName] LIKE 'Reistijd%' THEN 'Reistijd'         
          --WHEN H.Billable = 1 AND ([RateName] LIKE 'Normaal Decl.%' OR [RateName] LIKE 'Weekend%' OR RateName LIKE '>9%') THEN 'Declarabel'          
          WHEN H.Billable = 1 THEN 'Declarabele uren'          
          WHEN S.ProductNomination = '[unknown]' THEN T.TaskName          
          ELSE S.ProductNomination     
     END     
     , D.[DWMonthNumber]     
     , EmpCount = COUNT(DISTINCT H.EmployeeKey)     
     , HoursWritten = SUM(H.[Hours]*(H.[Percentage]/100.0))     
     FROM 
	      [Fact].[Hour] H     
          INNER JOIN [Dim].[Service] S ON S.ServiceKey = H.ServiceKey
          INNER JOIN [Dim].[HourType] HT ON HT.HourTypeKey = H.HourTypeKey
          INNER JOIN [Dim].[Task] T ON T.TaskKey = H.TaskKey
          INNER JOIN [Dim].[Project] P ON P.ProjectKey = H.ProjectKey
          INNER JOIN [Dim].[Customer] C ON C.CustomerKey = H.CustomerKey
          INNER JOIN [Dim].[Ledger] L ON L.LedgerKey = H.LedgerKey
          INNER JOIN [Dim].[Date] D ON D.[Date] = H.[Day]
          INNER JOIN [Dim].[Employee] E ON E.EmployeeKey = H.EmployeeKey
     WHERE 
	      [Day] >= '2018-01-01' 
	      AND P.ProductGroup IN ('OGD Intern', '[unknown]') 
	      AND S.ProductNomination IN ('Bankzitten', 'Ziekte', 'HR', 'Recruitment', 'Buitengewoon verlof', 'P&O - Reïntegratie') 
	      OR P.ProjectName = 'Reintegratie' 
		  OR P.ProjectGroupName = 'P&O gerelateerd (OGD intern)' 
	      OR T.TaskName IN ('Bankzitten', 'Ziekte', 'HR', 'Recruitment', 'Buitengewoon verlof', 'P&O - Reïntegratie')     
     GROUP BY     
          E.[BusinessUnit]
          , E.[Function]
          , L.[Text]
          , L.[Description]
          , P.Office
          , P.ProductGroup     
          , CASE     
                WHEN HT.[RateName] LIKE 'Reistijd%' THEN 'Reistijd'     
                --WHEN H.Billable = 1 AND ([RateName] LIKE 'Normaal Decl.%' OR [RateName] LIKE 'Weekend%' OR RateName LIKE '>9%') THEN 'Declarabel'     
                WHEN H.Billable = 1 THEN 'Declarabele uren'     
                WHEN S.ProductNomination = '[unknown]' THEN T.TaskName     
                ELSE S.ProductNomination     
            END     
          ,D.[DWMonthNumber]
	
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