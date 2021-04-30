CREATE procedure [Fact].[usp_mergeChangesForCustomer] (
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

	MERGE Fact.Change T
	USING (
		-- Deserializing JSON object
		select 
			 J.*
			,[CoordinatorGroupKey] = O.OperatorGroupKey
			,[RequestAuthorizationOperatorKey] = O1.OperatorGroupKey
			,[ProgressAuthorizationOperatorKey] = O2.OperatorGroupKey
			,[EvaluationAuthorizationOperatorKey] = O3.OperatorGroupKey
		FROM openjson(@SerializedJson) WITH (
			 [Guid] [uniqueidentifier] '$.Guid'
			--,[CustomerKey] [int] '$.CustomerKey'
			--,[CustomerNumber] [nvarchar](6) '$.CustomerNumber'
			,[ChangeNumber] [nvarchar](255) '$.ChangeNumber'
			,[DescriptionBrief] [nvarchar](255) '$.DescriptionBrief'
			,[CoordinatorGuid] [uniqueidentifier] '$.CoordinatorGuid'
			,[Coordinator] [nvarchar](255) '$.Coordinator'
			,[RequestAuthorizationOperatorGuid] [uniqueidentifier] '$.RequestAuthorizationOperatorGuid'
			,[RequestAuthorizationOperator] [nvarchar](255) '$.RequestAuthorizationOperator'
			,[ProgressAuthorizationOperatorGuid] [uniqueidentifier] '$.ProgressAuthorizationOperatorGuid'
			,[ProgressAuthorizationOperator] [nvarchar](255) '$.ProgressAuthorizationOperator'
			,[EvaluationAuthorizationOperatorGuid] [uniqueidentifier] '$.EvaluationAuthorizationOperatorGuid'
			,[EvaluationAuthorizationOperator] [nvarchar](255) '$.EvaluationAuthorizationOperator'
			,[CreationDate] [datetime2](7) '$.CreationDate'
			,[CompletionDate] [datetime2](7) '$.CompletionDate'
			,[ChangeDate] [datetime2](7) '$.ChangeDate'
			,[Status] [int] '$.Status'
			,[TicketStatus] [nvarchar](255) '$.TicketStatus'
			,[CurrentPhase] [INT] '$.CurrentPhase'
			,[ChangeType] [nvarchar](255) '$.ChangeType'
			,[TargetDate] datetime2 '$.TargetDate'
		) J 
		LEFT JOIN Dim.OperatorGroup O ON (O.OperatorGroupGuid = J.[CoordinatorGuid] AND O.CustomerKey = @CustomerKey)
		LEFT JOIN Dim.OperatorGroup O1 ON (O1.OperatorGroupGuid = J.[RequestAuthorizationOperatorGuid] AND O1.CustomerKey = @CustomerKey)
		LEFT JOIN Dim.OperatorGroup O2 ON (O2.OperatorGroupGuid = J.[ProgressAuthorizationOperatorGuid] AND O2.CustomerKey = @CustomerKey)
		LEFT JOIN Dim.OperatorGroup O3 ON (O3.OperatorGroupGuid = J.[EvaluationAuthorizationOperatorGuid] AND O3.CustomerKey = @CustomerKey)
		) S
		ON (T.CustomerKey = @CustomerKey AND T.[Guid] = S.[Guid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			 T.[ChangeNumber] = S.[ChangeNumber]
			,T.[DescriptionBrief] = S.[DescriptionBrief]
			,T.[CoordinatorGroupKey] = S.[CoordinatorGroupKey]
			,T.[CoordinatorGuid] = S.[CoordinatorGuid]
			,T.[Coordinator] = S.[Coordinator]
			,T.[RequestAuthorizationOperatorKey] = S.[RequestAuthorizationOperatorKey]
			,T.[RequestAuthorizationOperatorGuid] = S.[RequestAuthorizationOperatorGuid]
			,T.[RequestAuthorizationOperator] = S.[RequestAuthorizationOperator]
			,T.[ProgressAuthorizationOperatorKey] = S.[ProgressAuthorizationOperatorKey]
			,T.[ProgressAuthorizationOperatorGuid] = S.[ProgressAuthorizationOperatorGuid]
			,T.[ProgressAuthorizationOperator] = S.[ProgressAuthorizationOperator]
			,T.[EvaluationAuthorizationOperatorKey] = S.[EvaluationAuthorizationOperatorKey]
			,T.[EvaluationAuthorizationOperatorGuid] = S.[EvaluationAuthorizationOperatorGuid]
			,T.[EvaluationAuthorizationOperator] = S.[EvaluationAuthorizationOperator]
			,T.[CreationDate] = S.[CreationDate]
			,T.[CompletionDate] = S.[CompletionDate]
			,T.[ChangeDate] = S.[ChangeDate]
			,T.[Status] = S.[Status]
			,T.[TicketStatus] = S.[TicketStatus]
			,T.[CurrentPhase] = S.[CurrentPhase]
			,T.[ChangeType] = S.[ChangeType]
			,T.[TargetDate] = S.[TargetDate]
		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([Guid], [CustomerKey], [CustomerNumber], [ChangeNumber], [DescriptionBrief], [CoordinatorGroupKey], [CoordinatorGuid], [Coordinator], [RequestAuthorizationOperatorKey], [RequestAuthorizationOperatorGuid], [RequestAuthorizationOperator], [ProgressAuthorizationOperatorKey], [ProgressAuthorizationOperatorGuid], [ProgressAuthorizationOperator], [EvaluationAuthorizationOperatorKey], [EvaluationAuthorizationOperatorGuid], [EvaluationAuthorizationOperator], [CreationDate], [CompletionDate], [ChangeDate], [Status], [TicketStatus], [CurrentPhase], [ChangeType],[TargetDate])
			VALUES
				(S.[Guid], @CustomerKey, @CustomerNumber, [ChangeNumber], [DescriptionBrief], [CoordinatorGroupKey], [CoordinatorGuid], [Coordinator], [RequestAuthorizationOperatorKey], [RequestAuthorizationOperatorGuid], [RequestAuthorizationOperator], [ProgressAuthorizationOperatorKey], [ProgressAuthorizationOperatorGuid], [ProgressAuthorizationOperator], [EvaluationAuthorizationOperatorKey], [EvaluationAuthorizationOperatorGuid], [EvaluationAuthorizationOperator], [CreationDate], [CompletionDate], [ChangeDate], [Status], [TicketStatus], [CurrentPhase], [ChangeType],[TargetDate])
		;

	RETURN 0
END