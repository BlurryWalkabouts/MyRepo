CREATE procedure [Fact].[usp_mergeChangeActivitiesForCustomer] (
	@CustomerNumber nvarchar(10),
	@SerializedJson nvarchar(max)
) 
with execute as owner
AS
BEGIN
	-- Verifying format of customernumber
	IF @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9]' AND @CustomerNumber NOT LIKE '00[0-9][0-9][0-9][0-9].[0-9][0-9][0-9]'  BEGIN
		THROW 51000, 'Invalid customernumber, expected 00[0-9]{4} OR 00[0-9]{4}.[0-9]{3} as pattern', 1;
	END 

	DECLARE @CustomerKey INT = (SELECT CustomerKey FROM Dim.Customer WHERE CustomerNumber = @CustomerNumber)

	MERGE Fact.ChangeActivity T
	USING (
		-- Deserializing JSON object
		select J.*, O.[OperatorGroup],  ChangeKey =  C.Change_ID, O.OperatorGroupKey from openjson(@SerializedJson) WITH (
			[Guid] [uniqueidentifier] '$.Guid',
			[ChangeGuid] [uniqueidentifier] '$.ChangeGuid',
			[ChangeNumber] [nvarchar](255) '$.ChangeNumber',
			[CustomerKey] [int] '$.CustomerKey',
			[CustomerNumber] [nvarchar](6) '$.CustomerNumber',
			[ActivityNumber] [nvarchar](255) '$.ActivityNumber',
			[ChangeBriefDescription] [nvarchar](255) '$.ChangeBriefDescription',
			[BriefDescription] [nvarchar](255) '$.BriefDescription',
			[OperatorGroupGuid] [uniqueidentifier] '$.OperatorGroupGuid',
			--[OperatorGroup] [nvarchar](255) '$.OperatorGroup',
			[OperatorKey] [int] '$.OperatorKey',
			[OperatorGuid] [uniqueidentifier] '$.OperatorGuid',
			[Operator] [nvarchar](255) '$.Operator',
			[CreationDate] [datetime2](7) '$.CreationDate',
			[ClosureDate] [datetime2](7) '$.ClosureDate',
			[PlannedFinalDate] [date] '$.PlannedFinalDate',
			[ChangeDate] [datetime2](7) '$.ChangeDate',
			[Status] [nvarchar](255) '$.Status',
			[Started] [bit] '$.Started',
			[Skipped] [bit] '$.Skipped',
			[Rejected] [bit] '$.Rejected',
			[Resolved] [bit] '$.Resolved',
			[MayStart] [bit] '$.MayStart'
		) J
		INNER JOIN Fact.Change C ON (C.Guid = J.ChangeGuid)
		LEFT JOIN Dim.OperatorGroup O ON (O.OperatorGroupGuid = J.OperatorGroupGuid AND O.CustomerKey = @CustomerKey)
		) S
		ON (T.CustomerKey = @CustomerKey AND T.[Guid] = S.[Guid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			T.[ChangeBriefDescription] = S.[ChangeBriefDescription],
			T.[BriefDescription] = S.[BriefDescription],
			T.[OperatorGroupKey] = S.[OperatorGroupKey],
			T.[OperatorGroupGuid] = S.[OperatorGroupGuid],
			T.[OperatorGroup] = S.[OperatorGroup],
			T.[OperatorKey] = S.[OperatorKey],
			T.[OperatorGuid] = S.[OperatorGuid],
			T.[Operator] = S.[Operator],
			T.[CreationDate] = S.[CreationDate],
			T.[ClosureDate] = S.[ClosureDate],
			T.[PlannedFinalDate] = S.[PlannedFinalDate],
			T.[ChangeDate] = S.[ChangeDate],
			T.[Status] = S.[Status],
			T.[Started] = S.[Started],
			T.[Skipped] = S.[Skipped],
			T.[Rejected] = S.[Rejected],
			T.[Resolved] = S.[Resolved],
			T.[MayStart] = S.[MayStart]
		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([Guid],[ChangeKey],[ChangeGuid],[ChangeNumber],[CustomerKey],[CustomerNumber],[ActivityNumber],[ChangeBriefDescription],[BriefDescription],[OperatorGroupKey],[OperatorGroupGuid],[OperatorGroup],[OperatorKey],[OperatorGuid],[Operator],[CreationDate],[ClosureDate],[PlannedFinalDate],[ChangeDate],[Status],[Started],[Skipped],[Rejected],[Resolved],[MayStart])
			VALUES
				([Guid],[ChangeKey],[ChangeGuid],[ChangeNumber],@CustomerKey,@CustomerNumber,[ActivityNumber],[ChangeBriefDescription],[BriefDescription],[OperatorGroupKey],[OperatorGroupGuid],[OperatorGroup],[OperatorKey],[OperatorGuid],[Operator],[CreationDate],[ClosureDate],[PlannedFinalDate],[ChangeDate],[Status],[Started],[Skipped],[Rejected],[Resolved],[MayStart])
		;

	RETURN 0
END