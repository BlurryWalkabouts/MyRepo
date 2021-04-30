CREATE procedure [Fact].[usp_mergeProblemsForCustomer] (
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

	MERGE Fact.Problem T
	USING (
		-- Deserializing JSON object
		select J.*, O.OperatorGroupKey from openjson(@SerializedJson) WITH (
			[Guid] [uniqueidentifier] '$.Guid',
			[CustomerKey] [int] '$.CustomerKey',
			[CustomerNumber] [nvarchar](6) '$.CustomerNumber',
			[ProblemNumber] [nvarchar](255) '$.ProblemNumber',
			[ProblemDescription] [nvarchar](255) '$.ProblemDescription',
			--[OperatorGroupKey] [int] '$.OperatorGroupKey',
			[OperatorGroupGuid] [uniqueidentifier] '$.OperatorGroupGuid',
			[OperatorGroup] [nvarchar](255) '$.OperatorGroup',
			[OperatorKey] [int] '$.OperatorKey',
			[OperatorGuid] [uniqueidentifier] '$.OperatorGuid',
			[Operator] [nvarchar](255) '$.Operator',
			[CreationDate] [datetime2](7) '$.CreationDate',
			[ProblemDate] [datetime2](7) '$.ProblemDate',
			[CompletionDate] [datetime2](7) '$.CompletionDate',
			[ClosureDate] [datetime2](7) '$.ClosureDate',
			[ChangeDate] [datetime2](7) '$.ChangeDate',
			[ProblemType] [nvarchar](255) '$.ProblemType',
			[StatusID] [int] '$.StatusID',
			[Status] [nvarchar](255) '$.Status',
			[TargetDate] datetime2 '$.TargetDate'
		) J
		LEFT JOIN Dim.OperatorGroup O ON (O.OperatorGroupGuid = J.OperatorGroupGuid AND O.CustomerKey = @CustomerKey)) S
		ON (T.CustomerKey = @CustomerKey AND T.[Guid] = S.[Guid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			T.[ProblemDescription] = S.[ProblemDescription],
			T.[OperatorGroupKey] = S.[OperatorGroupKey],
			T.[OperatorGroupGuid] = S.[OperatorGroupGuid],
			T.[OperatorGroup] = S.[OperatorGroup],
			T.[OperatorKey] = S.[OperatorKey],
			T.[OperatorGuid] = S.[OperatorGuid],
			T.[Operator] = S.[Operator],
			T.[CreationDate] = S.[CreationDate],
			T.[ProblemDate] = S.[ProblemDate],
			T.[CompletionDate] = S.[CompletionDate],
			T.[ClosureDate] = S.[ClosureDate],
			T.[ChangeDate] = S.[ChangeDate],
			T.[ProblemType] = S.[ProblemType],
			T.[StatusID] = S.[StatusID],
			T.[Status] = S.[Status],
			T.[TargetDate] = S.[TargetDate]
		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([Guid],[CustomerKey],[CustomerNumber],[ProblemNumber],[ProblemDescription],[OperatorGroupKey],[OperatorGroupGuid],[OperatorGroup],[OperatorKey],[OperatorGuid],[Operator],[CreationDate],[ProblemDate],[CompletionDate],[ClosureDate],[ChangeDate],[ProblemType],[StatusID],[Status],[TargetDate])
			VALUES
				([Guid],@CustomerKey,@CustomerNumber,[ProblemNumber],[ProblemDescription],[OperatorGroupKey],[OperatorGroupGuid],[OperatorGroup],[OperatorKey],[OperatorGuid],[Operator],[CreationDate],[ProblemDate],[CompletionDate],[ClosureDate],[ChangeDate],[ProblemType],[StatusID],[Status],[TargetDate])
		;

	RETURN 0
END