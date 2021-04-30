CREATE VIEW [metadesk].[vwOperationalActivity] AS
SELECT [Id] = [OperationalActivity_Id]
      ,[Customer] = C.FullName
      ,P.[CustomerNumber]
      ,[TicketNumber] = [OperationalActivityNumber]
	  ,[OperationalSeriesNumber] = COALESCE([OperationalSeriesNumber], '')
	  ,[OperationalSeriesName] = COALESCE([OperationalSeriesName], '')
      ,[Description]
	  ,[DetailedDescription]
      ,[OperatorGroup] = COALESCE([OperatorGroup], '')
      ,[Operator] = COALESCE([Operator], '')
      ,[CreationDate]
	  ,[PlannedStartDate]
	  ,[PlannedCompletionDate]
      ,[ClosureDate] = [CompletionDate]
      ,[ChangeDate]
      ,[Status]
	  ,[TargetDateAchievedFlag]
	  ,[TargetDate] = plannedcompletiondate
	  ,[Type] = ''
	  ,[Url] = C.[TopdeskUrl] + [Url]
FROM [Fact].[OperationalActivity] P
INNER JOIN [Dim].[Customer] C ON (C.CustomerKey = P.CustomerKey)
WHERE Completed = 0 and Skipped = 0