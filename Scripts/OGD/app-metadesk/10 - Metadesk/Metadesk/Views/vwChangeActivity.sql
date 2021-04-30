CREATE VIEW [metadesk].[vwChangeActivity] AS (
	SELECT [Id] = [ChangeActivity_Id]
		  ,[ChangeNumber] = COALESCE(CA.[ChangeNumber], '')
		  ,CA.[CustomerNumber]
		  ,[Customer] = C.FullName
		  ,[TicketNumber] = [ActivityNumber]
		  ,[ChangeBriefDescription]
		  ,[Description] = CA.[ChangeNumber] + ' (' + [ChangeBriefDescription] + ')' + ' - ' + [BriefDescription]
		  ,[OperatorGroup] = COALESCE([OperatorGroup], '')
		  ,[Operator] = COALESCE([Operator], '')
		  ,CA.[CreationDate]
		  ,CA.[ClosureDate]
		  ,CA.[PlannedFinalDate]
		  ,CA.[ChangeDate]
		  ,CA.[Status]
		  ,[Started]
		  ,[MayStart]
		  ,CA.[TargetDateAchievedFlag]
		  ,[TargetDate] = PlannedFinalDate
		  ,[Type] = CRQ.ChangeType
		  ,[Url] = C.[TopdeskUrl] + CA.[Url]
		  ,[ParentUrl] = C.[TopdeskUrl] + [ParentUrl]
		  ,[ParentId] = ChangeKey
	  FROM [Fact].[ChangeActivity] CA
	  INNER JOIN [Dim].[Customer] C ON (C.CustomerKey = CA.CustomerKey)
	  INNER JOIN [Fact].[Change] CRQ ON (CRQ.Change_ID = CA.ChangeKey)
	  WHERE 
		ClosureDate IS NULL
		AND ([Started] = 1 OR MayStart = 1)
		AND ([Skipped] = 0 AND [Rejected] = 0 AND [Resolved] = 0)
)