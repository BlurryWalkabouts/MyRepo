CREATE PROCEDURE [Security].[usp_VerifyResourceGroups]
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
	 
		FETCH NEXT FROM resourceCursor   
		INTO @ResourceName, @ResourceRole  
	END   
	CLOSE resourceCursor;
	DEALLOCATE resourceCursor;
END