CREATE PROCEDURE [Security].[usp_VerifyResourceGroups] WITH EXECUTE AS OWNER
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @ResourceName nvarchar(255)
	DECLARE @ResourceRole nvarchar(255)

	DECLARE resourceCursor CURSOR FOR   
	SELECT [name], [roleName] 
	FROM [Security].[AzureGroup]

	OPEN resourceCursor  

	FETCH NEXT FROM resourceCursor   
	INTO @ResourceName, @ResourceRole

	WHILE @@FETCH_STATUS = 0  
	BEGIN  
		PRINT ' '
		PRINT '--- Verifying: ' + @ResourceName + ' ---'

		-- Check if role exists
		IF (SELECT COUNT(*) FROM [Security].[vwRoleMembership] WHERE DatabaseRoleName = @ResourceRole AND DataBaseUserName = @ResourceName) = 1 BEGIN
			PRINT 'No action required.'
		END
		ELSE BEGIN
			PRINT 'Attempting to recreate user and role mapping'
			EXEC [Security].[usp_AddResourceGroupUser] @ResourceName = @ResourceName
			EXEC [Security].[usp_AddResourceGroupRole] @ResourceName = @ResourceName
		END
	 
		-- Metadesk membership
		IF (SELECT COUNT(*) FROM [Security].[vwRoleMembership] WHERE DatabaseRoleName = 'metadesk' AND DataBaseUserName = @ResourceRole) = 1 BEGIN
			PRINT 'Metadesk Member - No action required.'
		END
		ELSE BEGIN
			PRINT 'Metadesk Member - Attempting to recreate user and role mapping'
			EXEC [Security].[usp_AddResourceGroupRoleToMetadesk] @ResourceName = @ResourceName
		END

		FETCH NEXT FROM resourceCursor   
		INTO @ResourceName, @ResourceRole  
	END   
	CLOSE resourceCursor;
	DEALLOCATE resourceCursor;
END