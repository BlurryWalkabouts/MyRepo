CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchChanges] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
	SELECT TOP 1500
		 -- Identifier
		 [Guid] = c.unid
		 -- Customer Identifier
		,[CustomerKey] = NULL
		,[CustomerNumber] = NULL
		-- Frontend Identifier
		,[ChangeNumber] = number
		,[DescriptionBrief] = briefdescription
		-- Group
		,[CoordinatorGroupKey] = NULL
		,[CoordinatorGuid] = managerid
		--,[Coordinator] = ref_manager_name
		,[Coordinator] = COALESCE(ad.naam, 'Not in replica')
		,[RequestAuthorizationOperatorGuid] = [req_authoperatorid]
		,[RequestAuthorizationOperator] = COALESCE(ao.naam, 'Not in replica')
		,[ProgressAuthorizationOperatorGuid] = [pro_authoperatorid]
		,[ProgressAuthorizationOperator] = COALESCE(po.naam, 'Not in replica')
		,[EvaluationAuthorizationOperatorGuid] = [eval_authoperatorid]
		,[EvaluationAuthorizationOperator] = COALESCE(eo.naam, 'Not in replica')
		-- Dates
		,[CreationDate] = c.dataanmk
		,[CompletionDate] = COALESCE(finaldate, rejecteddate, canceldate)
		,[ChangeDate] = c.datwijzig
		,[TargetDate] = PlannedFinalDate
		-- Status and types
		,C.[Status]
		,TicketStatus = COALESCE(S.[naam], '')
		,C.[CurrentPhase]
		--,[ChangeType] = ref_type_name
		,[ChangeType] = a.naam
		--,[Type] = ref_type_name
		,[Type] = a.naam
		,[TypeSTD] = NULL
	FROM
		dbo.change c
			LEFT JOIN dbo.wbaanvraagtype a ON (a.unid = c.typeid)
			LEFT JOIN dbo.actiedoor ad ON (ad.unid = c.managerid and ad.naam != '')
			LEFT JOIN dbo.actiedoor ao ON (ao.unid = c.req_authoperatorid and ao.naam != '')
			LEFT JOIN dbo.actiedoor po ON (po.unid = c.[pro_authoperatorid] and po.naam != '')
			LEFT JOIN dbo.actiedoor eo ON (eo.unid = c.[pro_authoperatorid] and eo.naam != '')
			LEFT JOIN dbo.wijzigingstatus S ON (S.unid = c.statusid)
	WHERE 
		-- Exclude Archived
		C.[Status] > 0
		-- Exclude Closed Changes
		AND c.datwijzig >= @LastModified
	ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END

GO