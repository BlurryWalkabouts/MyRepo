CREATE PROCEDURE [Security].[usp_AddGroupMapping] (
	@ResourceGroup nvarchar(255),
	@CustomerNumber nvarchar(10),
	@OperatorGroup nvarchar(255)
)
AS 
BEGIN
	IF @ResourceGroup IS NULL OR @CustomerNumber IS NULL OR @OperatorGroup IS NULL BEGIN
		THROW 16, 'No NULL parameters allowed.', 1
	END

	-- Declaring internal variables
	DECLARE @ResourceGroupId int = (SELECT id FROM Security.AzureGroup WHERE name = @ResourceGroup)
	DECLARE @CustomerKey int = (SELECT CustomerKey FROM Dim.Customer WHERE CustomerNumber = @CustomerNumber)

	-- Checks if parameters exists
	IF @ResourceGroupId IS NULL BEGIN
		THROW 16, 'Resourcegroup not found in Security.AzureGroup.', 9
	END
	IF @CustomerKey IS NULL BEGIN
		THROW 16, 'Customer not found in Dim.Customer.', 10
	END
	
	-- Declaring variable for OperatorGroupKey and checking validity
	DECLARE @OperatorGroupKey int
	DECLARE @OperatorGroupGuid uniqueidentifier
	
	SELECT @OperatorGroupKey = OperatorGroupKey, @OperatorGroupGuid = OperatorGroupGuid FROM Dim.OperatorGroup WHERE CustomerKey = @CustomerKey AND OperatorGroup = @OperatorGroup

	IF @OperatorGroupKey IS NULL BEGIN
		THROW 16, 'Operatorgroup with this name for this customer was not found in Dim.OperatorGroup.', 24
	END

	-- Check if mapping already exists
	IF (SELECT COUNT(*) FROM Security.AzureGroupMapping WHERE AzureGroupId = @ResourceGroupId AND CustomerKey = @CustomerKey AND OperatorGroupKey = @OperatorGroupKey AND OperatorGroupGuid = @OperatorGroupGuid) > 0 BEGIN
		THROW 16, 'Mapping already exists.', 35
	END
	
	INSERT INTO Security.AzureGroupMapping (AzureGroupID, CustomerKey, OperatorGroupKey, OperatorGroupGuid)
	VALUES (@ResourceGroupId, @CustomerKey, @OperatorGroupKey, @OperatorGroupGuid)
END