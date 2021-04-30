CREATE PROCEDURE [Security].[usp_AddResourceGroupRoleToMetadesk] (
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
	
	-- Checking if ResourceName is already a member of the role.
	IF (SELECT COUNT(*) FROM [Security].[vwRoleMembership] WHERE DatabaseRoleName = 'metadesk' AND DataBaseUserName = @ResourceRole) > 0 BEGIN
		PRINT 'Resourcegroup has already been mapped to Metadesk.'
	END
	ELSE BEGIN
		PRINT 'Mapping resourcegroup to role.' 
		EXEC('ALTER ROLE [metadesk] ADD MEMBER [' + @ResourceRole + '];')
	END
END