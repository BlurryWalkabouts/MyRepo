CREATE VIEW [metadesk].[vwChange] AS
  -- Current Phase:
  -- 2 = Ready to Start
  -- 3 = Rejected
  -- 5 = In Progress
  -- 6 = Evaluation
  -- 7 = Closed
  -- 8 = Cancelled
SELECT [Id] = [Change_Id]
      ,[Customer] = M.FullName
      ,C.[CustomerNumber]
      ,[TicketNumber] = [ChangeNumber]
      ,[Description] = [DescriptionBrief]
	  ,[OperatorGroup] = COALESCE([Coordinator], '')
      ,[Operator] = 
		CASE 
			WHEN CurrentPhase = 2 THEN COALESCE([RequestAuthorizationOperator], '')
			WHEN CurrentPhase = 5 THEN COALESCE([ProgressAuthorizationOperator], '')
			WHEN CurrentPhase = 6 THEN COALESCE([EvaluationAuthorizationOperator], '')
			ELSE 'Operator & Phase data not in replica'
		END
      ,[CreationDate]
      ,[ClosureDate] = [CompletionDate]
      ,[ChangeDate]
      ,[Status] = 
	  	CASE 
			WHEN CurrentPhase = 2 THEN COALESCE('Request', 'Phase data unavailable')
			WHEN CurrentPhase = 3 THEN COALESCE('Rejected', 'Phase data unavailable')
			WHEN CurrentPhase = 5 THEN COALESCE('In Progress', 'Phase data unavailable')
			WHEN CurrentPhase = 6 THEN COALESCE('Evaluation', 'Phase data unavailable')
			WHEN CurrentPhase = 7 THEN COALESCE('Closed', 'Phase data unavailable')
			WHEN CurrentPhase = 8 THEN COALESCE('Cancelled', 'Phase data unavailable')
			ELSE 'Operator & Phase data not in replica'
		END
	  ,[TargetDateAchievedFlag]
	  ,[TargetDate]
      ,[Type] = [ChangeType]
	  ,[Url] = M.[TopdeskUrl] + [Url]
	  ,[ActiveActivityCount] = COALESCE([ActivityCount], 0)
  FROM [Fact].[Change] C
  INNER JOIN Dim.Customer M ON (M.CustomerKey = C.CustomerKey)
	LEFT JOIN (
		SELECT 
			 ParentId
			,ActivityCount = COUNT(*) 
		FROM [metadesk].[vwChangeActivity] 
		GROUP BY ParentId
	) CA ON (CA.ParentId = C.[Change_Id])
  WHERE C.CompletionDate IS NULL AND CurrentPhase IN (2,5,6)
GO