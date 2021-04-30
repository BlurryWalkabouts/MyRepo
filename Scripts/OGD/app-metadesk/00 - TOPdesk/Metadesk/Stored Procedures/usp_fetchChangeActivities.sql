CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchChangeActivities] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
SELECT TOP 1500
	 -- Identifier
       [Guid] = ca.unid
      ,[ChangeKey] = NULL
	  ,[ChangeGuid] = ca.changeid
      --,[ChangeNumber] = ref_change_number
      ,[ChangeNumber] = c.number
      ,[CustomerKey] = NULL
      ,[CustomerNumber] = NULL
      ,[ActivityNumber] = ca.number
	  ,[ChangeBriefDescription] = c.briefdescription
      ,[BriefDescription] = ca.briefdescription
      ,[OperatorGroupKey] = NULL
      ,[OperatorGroupGuid] = ca.operatorgroupid
      --,[OperatorGroup] = ref_operator_name
      ,[OperatorGroup] = opg.naam
      ,[OperatorKey] = NULL
      ,[OperatorGuid] = ca.operatorid
      --,[Operator] = ref_operator_name
      ,[Operator] = 
		CASE 
			WHEN op.naam != '' THEN op.naam
			WHEN op.tasloginnaam != '' then op.tasloginnaam
		ELSE
			'Not in replica'
		END
      ,[CreationDate] = ca.dataanmk
      ,[ClosureDate] = COALESCE(ca.resolveddate, ca.skippeddate, ca.rejecteddate)
      ,[PlannedFinalDate] = ca.plannedfinaldate
      ,[ChangeDate] = ca.datwijzig
      ,[Status] = ca.status
	  ,ca.[Started]
	  ,ca.[Skipped]
	  ,ca.[Rejected]
	  ,ca.[Resolved]
	  ,ca.[MayStart]
FROM
	dbo.changeactivity ca
        INNER JOIN dbo.change c ON c.unid = ca.changeid
        LEFT JOIN dbo.actiedoor op ON op.unid = ca.operatorid
        LEFT JOIN dbo.actiedoor opg ON opg.unid = ca.operatorgroupid
WHERE 
	ca.datwijzig >= @LastModified 
	-- Exclude Archived
	AND ca.[Status] > 0
ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END