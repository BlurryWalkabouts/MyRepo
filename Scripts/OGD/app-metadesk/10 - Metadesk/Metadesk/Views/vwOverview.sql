CREATE VIEW [metadesk].[vwOverview] AS
SELECT 
	 [Id]
	,[TicketType] = 'I'
	,[TicketNumber]
	,[Customer]
	,[CustomerNumber]
	,[Status]
	,[Description]
	,[CreationDate]
	,[ClosureDate]
	,[ChangeDate]
	,[Type] = COALESCE([Type], ' ---')
	,[Url]
	,[Operator]
	,[OperatorGroup]
	,[TargetDateAchievedFlag]
	,[TargetDate]
FROM metadesk.vwIncident
UNION
SELECT  
	 [Id]
	,[TicketType] = 'W'
	,[TicketNumber]
	,[Customer]
	,[CustomerNumber]
	,[Status]
	,[Description]
	,[CreationDate]
	,[ClosureDate]
	,[ChangeDate]
	,[Type] = COALESCE([Type], ' ---')
	,[Url]
	,[Operator]
	,[OperatorGroup]
	,[TargetDateAchievedFlag]
	,[TargetDate]
FROM metadesk.vwChange
UNION
SELECT  
	 [Id]
	,[TicketType] = 'WA'
	,[TicketNumber]
	,[Customer]
	,[CustomerNumber]
	,[Status]
	,[Description]
	,[CreationDate]
	,[ClosureDate]
	,[ChangeDate]
	,[Type] = COALESCE([Type], ' ---')
	,[Url]
	,[Operator]
	,[OperatorGroup]
	,[TargetDateAchievedFlag]
	,[TargetDate]
FROM metadesk.vwChangeActivity
UNION
SELECT  
	 [Id]
	,[TicketType] = 'P'
	,[TicketNumber]
	,[Customer]
	,[CustomerNumber]
	,[Status]
	,[Description]
	,[CreationDate]
	,[ClosureDate]
	,[ChangeDate]
	,[Type] = COALESCE([Type], ' ---')
	,[Url]
	,[Operator]
	,[OperatorGroup]
	,[TargetDateAchievedFlag]
	,[TargetDate]
FROM metadesk.vwProblem
UNION
SELECT  
	 [Id]
	,[TicketType] = 'O'
	,[TicketNumber]
	,[Customer]
	,[CustomerNumber]
	,[Status]
	,[Description]
	,[CreationDate]
	,[ClosureDate]
	,[ChangeDate]
	,[Type] = COALESCE([Type], ' ---')
	,[Url]
	,[Operator]
	,[OperatorGroup]
	,[TargetDateAchievedFlag]
	,[TargetDate]
FROM metadesk.vwOperationalActivity