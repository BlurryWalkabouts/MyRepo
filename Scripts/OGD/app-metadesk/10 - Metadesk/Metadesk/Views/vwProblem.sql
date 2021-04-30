CREATE VIEW [metadesk].[vwProblem] AS
SELECT [Id] = [Problem_Id]
      ,[Customer] = C.FullName
      ,P.[CustomerNumber]
      ,[TicketNumber] = [ProblemNumber]
      ,[Description] = [ProblemDescription]
      ,[OperatorGroup] = COALESCE(G.OperatorGroup, P.OperatorGroup, '')
      ,[Operator] = COALESCE([Operator], '')
	  ,[ProblemCoordinator] = COALESCE(P.OperatorGroup, '')
      ,[CreationDate]
	  ,[ProblemDate]
	  ,[CompletionDate]
      ,[ClosureDate]
      ,P.[ChangeDate]
      ,[Status]
	  ,[TargetDateAchievedFlag]
	  ,[TargetDate]
	  ,[Type] = [ProblemType]
	  ,[Url] = C.[TopdeskUrl] + [Url]
FROM [Fact].[Problem] P
INNER JOIN [Dim].[Customer] C ON (C.CustomerKey = P.CustomerKey)
LEFT JOIN [Dim].[OperatorGroup] G ON (G.OperatorGroupKey = P.OperatorGroupKey)
WHERE ClosureDate IS NULL