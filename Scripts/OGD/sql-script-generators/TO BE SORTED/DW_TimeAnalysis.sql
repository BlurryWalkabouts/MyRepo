SELECT 
        C.Fullname
       ,DurationActual
       ,DurationAdjusted
       ,DurationAdjustedActualCombi
       ,DurationOnHold
	   -- Duration is de looptijd die aan een melding mag hangen ivm prioriteit en urgentie. Dit is niet een berekend veld!
       ,Duration
       ,Creation = CAST(CreationDate AS DATETIME) +  CAST(CreationTime AS DATETIME)
	   ,Incident = CAST(IncidentDate AS DATETIME) +  CAST(IncidentTime AS DATETIME)
       ,Completion = CASE WHEN CompletionDate IS NULL THEN GETUTCDATE() ELSE CAST(CompletionDate AS DATETIME) + CAST(CompletionTime AS DATETIME) END
	   ,Closed = CASE WHEN ClosureDate IS NULL THEN GETUTCDATE() ELSE CAST(ClosureDate AS DATETIME) + CAST(ClosureTime AS DATETIME) END
       ,DATEDIFF(s, CAST(CreationDate AS DATETIME) +  CAST(CreationTime AS DATETIME), CAST(CompletionDate AS DATETIME) + CAST(CompletionTime AS DATETIME))
       ,NewDuration = DATEDIFF(s, CAST(IncidentDate AS DATETIME) +  CAST(IncidentTime AS DATETIME), CASE WHEN CompletionDate IS NULL THEN GETUTCDATE() ELSE CAST(CompletionDate AS DATETIME) + CAST(CompletionTime AS DATETIME) END)
FROM [OGDW].[Fact].[Incident] I
INNER JOIN [OGDW].DIM.Customer C ON (C.CustomerKey = I.CustomerKey)
WHERE Fullname = 'Kennedy van der Laan' AND CreationDate > '2015-12-31' AND (DATEDIFF(s, CAST(CreationDate AS DATETIME) +  CAST(CreationTime AS DATETIME), CAST(CompletionDate AS DATETIME) + CAST(CompletionTime AS DATETIME)))  < 0
ORDER BY NewDuration 
