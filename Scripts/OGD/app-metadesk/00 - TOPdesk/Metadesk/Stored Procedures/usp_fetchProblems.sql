CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchProblems] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
SELECT TOP 1500
	 -- Identifier
	 [Guid] = p.unid
	,[CustomerKey] = NULL
	,[CustomerNumber] = NULL
	,[ProblemNumber] = p.naam
	,[ProblemDescription] = p.refcombi_korteomschrijving
	--,[ProblemDescription] = 'not in replica'
	,[OperatorGroupKey] = NULL
	,[OperatorGroupGuid] = operatorgroupid
	,[OperatorGroup] = opg.naam
	,[OperatorKey] = NULL
	,[OperatorGuid] = NULL
	,[Operator] = NULL
	,[CreationDate] = p.dataanmk
	,[ProblemDate] = aanmaakdatum
	,[CompletionDate] = datumgereed
	,[ClosureDate] = datumafgemeld
	,[ChangeDate] = p.datwijzig
	,[ProblemType] = NULL
	,[StatusID] = p.Status
	,[Status] = ps.naam
	,[TargetDate] = streefdatum
FROM
	dbo.probleem p
        LEFT JOIN dbo.actiedoor opg ON opg.unid = p.operatorgroupid
        LEFT JOIN probleem_status ps on ps.unid = p.statusid
WHERE 
	p.datwijzig >= @LastModified 
	-- Exclude Archived
	AND p.[Status] > 0
	-- Exclude Closed
	AND p.datwijzig >= @LastModified
ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END
GO