CREATE procedure [Dim].[usp_mergeOperatorGroupsForCustomer] (
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

	MERGE Dim.OperatorGroup T
	USING (
		-- Deserializing JSON object
		select * from openjson(@SerializedJson) WITH (
			 [OperatorGroupGuid] [uniqueidentifier] '$.OperatorGroupGuid'
			,[OperatorGroup] [nvarchar](255) '$.OperatorGroup'
			,[ChangeDate] [datetime2](7) '$.ChangeDate'
		)) S
		ON (T.CustomerKey = @CustomerKey AND T.[OperatorGroupGuid] = S.[OperatorGroupGuid])
		WHEN MATCHED THEN UPDATE SET
			-- Update existing records
			 T.[OperatorGroup] = S.[OperatorGroup],
			 T.[ChangeDate] = S.[ChangeDate]

		WHEN NOT MATCHED  BY TARGET THEN INSERT
			([CustomerKey],[CustomerNumber],[OperatorGroupGuid],[OperatorGroup],[ChangeDate])
			VALUES
				(@CustomerKey,@CustomerNumber,[OperatorGroupGuid],[OperatorGroup],[ChangeDate])
		;

	RETURN 0
END