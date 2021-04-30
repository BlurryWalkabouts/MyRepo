

CREATE view [Dim].[vwSLA] as 

select 
      [Code]
	  ,Name
      ,[CallResponseTimeValue]
      ,[CallResponseTimeRate]
      ,[CallDurationValue]
      ,[CallDurationRate]
	  ,[MailResponseTimeValue]
	  ,[MailResponseTimeRate]
	  ,[IncidentFirstlineResolveRate]
      ,[IncidentVerstoringResolveRate]
      ,[IncidentFirstlineDuration]
      ,[IncidentSecondlineDuration]
      ,[StandardChangeDurationRate]
      ,[IncidentVerstoringP1ResolveRate]
      ,[IncidentVerstoringP2ResolveRate]
      ,[IncidentVerstoringP3ResolveRate]
      ,[IncidentAanvraagP5ResolveRate]
      ,[IncidentVraagP5ResolveRate]
	  ,[KlachtResolveRate]
	  ,[ProblemResolveRate]
	  ,[ChangeAuthTimeValue]
	  ,[ChangeAuthTimeRate]
	  ,[ChangeClosingTimeValue]
	  ,[ChangeClosingTimeRate]
from Dim.SLA

/*

 Changed from MDS to Batch 


SELECT 
      [Code]
	  ,Name
      ,[CallResponseTimeValue]
      ,[CallResponseTimeRate]
      ,[CallDurationValue]
      ,[CallDurationRate]
	  ,[MailResponseTimeValue]
	  ,[MailResponseTimeRate]
	  ,[IncidentFirstlineResolveRate]
      ,[IncidentVerstoringResolveRate]
      ,[IncidentFirstlineDuration]
      ,[IncidentSecondlineDuration]
      ,[StandardChangeDurationRate]
      ,[IncidentVerstoringP1ResolveRate]
      ,[IncidentVerstoringP2ResolveRate]
      ,[IncidentVerstoringP3ResolveRate]
      ,[IncidentAanvraagP5ResolveRate]
      ,[IncidentVraagP5ResolveRate]
	  ,[KlachtResolveRate]
	  ,[ProblemResolveRate]
	  ,[ChangeAuthTimeValue]
	  ,[ChangeAuthTimeRate]
	  ,[ChangeClosingTimeValue]
	  ,[ChangeClosingTimeRate]

  FROM [MDS].[mdm].[DimSLA]

*/







