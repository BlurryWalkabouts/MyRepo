CREATE VIEW [metadesk].[vwIncident] AS
SELECT [Id] = [Incident_Id]
      ,[Customer] = C.FullName
      ,I.[CustomerNumber]
      ,[TicketNumber] = [IncidentNumber]
      ,[Description] = [IncidentDescription]
      ,[OperatorGroup] = COALESCE([OperatorGroup], '')
      ,[Operator] = COALESCE([Operator], '')
      ,[CreationDate]
      ,[IncidentDate]
      ,[CompletionDate]
      ,[ClosureDate]
      ,[ChangeDate]
      ,[Status]
	  ,[SlaAchievedFlag]
	  ,[SlaTargetDate]
	  ,[TargetDateAchievedFlag] = [SlaAchievedFlag]
	  ,[TargetDate] = [SlaTargetDate]
	  ,[Type] = [IncidentType]
	  ,[Url] = C.[TopdeskUrl] + [Url]
  FROM [Fact].[Incident] I
  INNER JOIN Dim.Customer C ON (C.CustomerKey = I.CustomerKey)
  WHERE ClosureDate IS NULL and Status NOT LIKE '%Gereed%' and StatusID > 0