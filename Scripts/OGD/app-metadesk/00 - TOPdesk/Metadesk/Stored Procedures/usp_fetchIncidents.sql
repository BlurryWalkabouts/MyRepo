CREATE OR ALTER PROCEDURE [metadesk].[usp_fetchIncidents] 
(
	@LastModified datetime2,
	@JsonSerializedResult nvarchar(max) OUTPUT
)
AS
BEGIN 

SET @JsonSerializedResult = (
	SELECT TOP 1500
		-- Identifier
		 Guid = i.unid
		-- Ticketnumber
		,IncidentNumber = i.naam
		,IncidentDescription = korteomschrijving
		-- Data
		,ChangeDate = datwijzig
		,CompletionDate = datumgereed
		,ClosureDate = datumafgemeld
		,CreationDate = dataanmk
		,SLATargetDate = datumafspraaksla
		,IncidentDate = datumaangemeld
		-- Type
		,IncidentType = ref_soortmelding
		-- Operator stuff. GUIDs + Textual names
		,OperatorgroupGuid = Operatorgroupid
		,OperatorGroup = ref_operatorgroup
		,OperatorGuid = OperatorId
		,Operator = ref_operatordynanaam
		-- Status ("Gereed Opgelost", etc')
		--,Status = 'not in replica'
		--,Status = vrijetekst1
		,Status = s.naam
		,StatusId = Status
		-- Needed for OGD multi-tenancy
		,[CustomerKey] = NULL
		,[CustomerNumber] = NULL
	FROM
		dbo.incident i
			LEFT JOIN dbo.afhandelingstatus s ON s.unid = i.afhandelingstatusid
	WHERE 
		-- Exclude Archived
		I.[Status] > 0
		AND i.datwijzig >= @LastModified
	ORDER BY ChangeDate ASC
FOR JSON PATH 
)
  RETURN 0
END

GO