CREATE PROCEDURE [Security].[usp_AddResourceGroup] (
	@ResourceName nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON 

	IF @ResourceName IS NULL BEGIN
		THROW 16, 'No NULLs allowed.', 1
	END

	-- Check if Resource already exists
	IF (SELECT COUNT(*) FROM [Security].[AzureGroup] WHERE name = @ResourceName) > 0 BEGIN
		THROW 16, 'Resourcegroup already exists in Security.AzureGroup. Run Security.usp_VerifyGroupRoles to fix mapping issues.', 1
	END

	-- Creating User for ResourceGroup
	EXEC [Security].[usp_AddResourceGroupUser] @ResourceName = @ResourceName

	-- Creating Role for ResourceGroup
	EXEC [Security].[usp_AddResourceGroupRole] @ResourceName = @ResourceName
END