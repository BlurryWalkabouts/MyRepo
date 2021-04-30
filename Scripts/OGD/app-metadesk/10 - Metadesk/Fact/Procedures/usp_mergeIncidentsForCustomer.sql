CREATE procedure [Fact].[usp_mergeIncidentsForCustomer] (
	@CustomerNumber nvarchar(10),
	@SerializedJson nvarchar(max)
)
WITH EXECUTE AS OWNER
AS
BEGIN
	-- Verifying format of customernumber
	IF @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9]' AND @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9].[0-9][0-9][0-9]'  BEGIN
		THROW 51000, 'Invalid customernumber, expected 00[0-9]{4} OR 00[0-9]{4}.[0-9]{3} as pattern', 1;
	END 

	DECLARE @CustomerKey INT = (SELECT CustomerKey FROM Dim.Customer WHERE CustomerNumber = @CustomerNumber)

	MERGE Fact.Incident T
	USING (
		-- Deserializing JSON object
		select J.*, O.OperatorGroupKey from openjson(@SerializedJson) WITH (
			 [Guid] [uniqueidentifier] '$.Guid'
			--,[CustomerKey] [int] '$.CustomerKey'
			--,[CustomerNumber] [nvarchar](6) '$.CustomerNumber'
			,[IncidentNumber] [nvarchar](255) '$.IncidentNumber'
			,[IncidentDescription] [nvarchar](255) '$.IncidentDescription'
			--,[OperatorGroupKey] [int] '$.OperatorGroupKey'
			,[OperatorGroupGuid] [uniqueidentifier] '$.OperatorgroupGuid'
			,[OperatorGroup] [nvarchar](255) '$.OperatorGroup'
			,[OperatorGuid] [uniqueidentifier] '$.OperatorGuid'
			,[Operator] [nvarchar](255) '$.Operator'
			,[CreationDate] [datetime2](7) '$.CreationDate'
			,[IncidentDate] [datetime2](7) '$.IncidentDate'
			,[CompletionDate] [datetime2](7) '$.CompletionDate'
			,[ClosureDate] [datetime2](7) '$.ClosureDate'
			,[ChangeDate] [datetime2](7) '$.ChangeDate'
			,[StatusID] [int] '$.StatusId'
			,[Status] [nvarchar](255) '$.Status'
			,[IncidentType] [nvarchar](255) '$.IncidentType'
			,[SlaTargetDate] [datetime2](7) '$.SLATargetDate'
		) J
		LEFT JOIN Dim.OperatorGroup O ON (O.OperatorGroupGuid = J.OperatorGroupGuid AND O.CustomerKey = @CustomerKey)) S
		ON (T.CustomerKey = @CustomerKey AND T.[Guid] = S.[Guid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			 T.[IncidentNumber] = S.[IncidentNumber]
			,T.[IncidentDescription] = S.[IncidentDescription]
			,T.[OperatorGroupKey] = S.[OperatorGroupKey]
			,T.[OperatorGroupGuid] = S.[OperatorGroupGuid]
			,T.[OperatorGroup] = S.[OperatorGroup]
			,T.[OperatorGuid] = S.[OperatorGuid]
			,T.[Operator] = S.[Operator]
			,T.[CreationDate] = S.[CreationDate]
			,T.[IncidentDate] = S.[IncidentDate]
			,T.[CompletionDate] = S.[CompletionDate]
			,T.[ClosureDate] = S.[ClosureDate]
			,T.[ChangeDate] = S.[ChangeDate]
			,T.[StatusID] = S.[StatusID]
			,T.[Status] = S.[Status]
			,T.[IncidentType] = S.[IncidentType]
			,T.[SlaTargetDate] = S.[SlaTargetDate]
		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([Guid], [CustomerKey], [CustomerNumber], [IncidentNumber], [IncidentDescription], [OperatorGroupKey], [OperatorGroupGuid], [OperatorGroup], [OperatorGuid], [Operator], [CreationDate], [IncidentDate], [CompletionDate], [ClosureDate], [ChangeDate], [StatusID], [Status], [StatusSTD], [IncidentType], [IncidentTypeSTD], [SlaTargetDate])
			VALUES
				(S.[Guid], @CustomerKey, @CustomerNumber, S.[IncidentNumber], S.[IncidentDescription], [OperatorGroupKey], S.[OperatorGroupGuid], S.[OperatorGroup], S.[OperatorGuid], S.[Operator], S.[CreationDate], S.[IncidentDate], S.[CompletionDate], S.[ClosureDate], S.[ChangeDate], S.[StatusID], S.[Status], NULL, S.[IncidentType], NULL, S.[SlaTargetDate])
		;

	RETURN 0
END