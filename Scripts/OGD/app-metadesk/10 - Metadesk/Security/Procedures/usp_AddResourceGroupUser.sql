CREATE PROCEDURE [Security].[usp_AddResourceGroupUser] (
	@ResourceName nvarchar(255)
)
AS
BEGIN
	SET NOCOUNT ON;

	IF @ResourceName IS NULL BEGIN
		THROW 16, 'No NULL values allowed.', 1
	END
	
	-- Verify if Role already exists
	IF (SELECT COUNT(*) FROM sys.database_principals WHERE [type] ='X' AND [name] = @ResourceName) > 0 BEGIN
		PRINT 'User already exists. Skipping creation phase.'
	END
	ELSE BEGIN
		PRINT 'Creating user.'
		EXEC('CREATE USER [' + @ResourceName + '] FROM EXTERNAL PROVIDER;')
	END
END