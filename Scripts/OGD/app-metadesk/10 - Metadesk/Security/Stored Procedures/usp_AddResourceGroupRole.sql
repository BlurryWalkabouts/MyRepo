CREATE PROCEDURE [Security].[usp_AddResourceGroupRole] (
	@ResourceName nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON

	IF @ResourceName IS NULL BEGIN
		THROW 16, 'No NULL values allowed.', 1
	END

	-- Declaring rolename
	DECLARE @ResourceRole nvarchar(259) = CONCAT('RLS_', @ResourceName)
	
	-- Verify if Role already exists
	IF (SELECT COUNT(*) FROM [Security].[vwRoleMembership] WHERE DatabaseRoleName = @ResourceRole) > 0 BEGIN
		PRINT 'Role already exists. Skipping creation phase.'
	END
	ELSE BEGIN
		PRINT 'Creating role.'
		EXEC('CREATE ROLE [' + @ResourceRole + '];')
	END

	-- Checking if ResourceName is already a member of the role.
	IF (SELECT COUNT(*) FROM [Security].[vwRoleMembership] WHERE DatabaseRoleName = @ResourceRole AND DataBaseUserName = @ResourceName) > 0 BEGIN
		PRINT 'Resourcegroup has already been mapped to role.'
	END
	ELSE BEGIN
		PRINT 'Mapping resourcegroup to role.' 
		EXEC('ALTER ROLE [' + @ResourceRole + '] ADD MEMBER [' + @ResourceName + '];')
	END

	-- Checking if Role has been added to Security.AzureGroup
	IF (SELECT COUNT(*) FROM [Security].[AzureGroup] WHERE [name] = @ResourceName and [roleName] = @ResourceRole) > 0 BEGIN
		PRINT 'Rolename already has been added to Security.AzureGroup'
	END
	ELSE BEGIN
		PRINT 'Updating record with rolename.'
		UPDATE [Security].[AzureGroup]
		SET [roleName] = @ResourceRole 
		WHERE [name] = @ResourceName
	END
END