CREATE procedure [Fact].[usp_mergeOperationalActivtiesForCustomer] (
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

	MERGE Fact.OperationalActivity T
	USING (
		-- Deserializing JSON object
		select J.*, O.OperatorGroupKey from openjson(@SerializedJson) WITH (
		   [Guid] [uniqueidentifier] '$.Guid'
		  --,[CustomerKey] [int] not null
		  --,[CustomerNumber] nvarchar(10) not null
		  ,[OperationalSeriesNumber] [nvarchar](255) '$.OperationalSeriesNumber'
		  ,[OperationalSeriesName] [nvarchar](255) '$.OperationalSeriesName'
		  ,[OperationalActivityNumber] [nvarchar](255) '$.OperationalActivityNumber'
		  ,[Description] [nvarchar](255) '$.Description'
		  ,[DetailedDescription] [nvarchar](max) '$.DetailedDescription'
		  --,[OperatorGroupKey] [int] '$.OperatorGroupKey'
		  ,[OperatorGroupGuid] [uniqueidentifier] '$.OperatorGroupGuid'
		  ,[OperatorGroup] [nvarchar](255) '$.OperatorGroup'
		  --,[OperatorKey] [int] '$.OperatorKey'
		  ,[OperatorGuid] [uniqueidentifier] '$.OperatorGuid'
		  ,[Operator] [nvarchar](255) '$.Operator'
		  ,[StatusID] [int] '$.StatusID'
		  ,[Status] [nvarchar](255) '$.Status'
		  ,[CreationDate] [datetime2] '$.CreationDate'
		  ,[ChangeDate] [datetime2] '$.ChangeDate'
		  ,[PlannedStartDate] [datetime2] '$.PlannedStartDate'
		  ,[PlannedCompletionDate] [datetime2] '$.PlannedCompletionDate'
		  ,[CompletionDate] [datetime2] '$.CompletionDate'
		  ,[Completed] [bit] '$.Completed'
		  ,[Skipped] [bit] '$.Skipped'
		) J
		LEFT JOIN Dim.OperatorGroup O ON (O.OperatorGroupGuid = J.OperatorGroupGuid AND O.CustomerKey = @CustomerKey)) S
		ON (T.CustomerKey = @CustomerKey AND T.[Guid] = S.[Guid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			 T.[OperationalSeriesNumber] = S.[OperationalSeriesNumber]
			,T.[OperationalSeriesName] = S.[OperationalSeriesName]
			,T.[OperationalActivityNumber] = S.[OperationalActivityNumber]
			,T.[Description] = S.[Description]
			,T.[DetailedDescription] = S.[DetailedDescription]
			,T.[OperatorGroupKey] = S.[OperatorGroupKey]
			,T.[OperatorGroupGuid] = S.[OperatorGroupGuid]
			,T.[OperatorGroup] = S.[OperatorGroup]
			,T.[OperatorGuid] = S.[OperatorGuid]
			,T.[Operator] = S.[Operator]
			,T.[StatusID] = S.[StatusID]
			,T.[Status] = S.[Status]
			,T.[CreationDate] = S.[CreationDate]
			,T.[ChangeDate] = S.[ChangeDate]
			,T.[PlannedStartDate] = S.[PlannedStartDate]
			,T.[PlannedCompletionDate] = S.[PlannedCompletionDate]
			,T.[CompletionDate] = S.[CompletionDate]
			,T.[Completed] = S.[Completed]
			,T.[Skipped] = S.[Skipped]
		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([Guid] ,[CustomerKey] ,[CustomerNumber] ,[OperationalSeriesNumber] ,[OperationalSeriesName] ,[OperationalActivityNumber] ,[Description] ,[DetailedDescription] ,[OperatorGroupKey] ,[OperatorGroupGuid] ,[OperatorGroup] ,[OperatorGuid] ,[Operator] ,[StatusID] ,[Status] ,[CreationDate] ,[ChangeDate] ,[PlannedStartDate] ,[PlannedCompletionDate] ,[CompletionDate] ,[Completed] ,[Skipped])
			VALUES
				(S.[Guid] ,@CustomerKey ,@CustomerNumber ,S.[OperationalSeriesNumber] ,S.[OperationalSeriesName] ,S.[OperationalActivityNumber] ,S.[Description] ,S.[DetailedDescription] ,S.[OperatorGroupKey] ,S.[OperatorGroupGuid] ,S.[OperatorGroup] ,S.[OperatorGuid] ,S.[Operator] ,S.[StatusID] ,S.[Status] ,S.[CreationDate] ,S.[ChangeDate] ,S.[PlannedStartDate] ,S.[PlannedCompletionDate] ,S.[CompletionDate] ,S.[Completed] ,S.[Skipped])
		;

	RETURN 0
END