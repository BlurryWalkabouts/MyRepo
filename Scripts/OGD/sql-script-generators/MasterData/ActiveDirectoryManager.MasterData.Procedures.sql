/*
CREATE USER [sa_ActiveDirectoryManager] WITH PASSWORD='radar-a%K6w/Yu*_9L34MUJ39WZ=S6Fz4dvrsgxptKgmfEinyx58h#s';
GO
CREATE ROLE [ActiveDirectoryManager];
GO
GRANT EXECUTE ON SCHEMA::[ActiveDirectoryManagement] TO [ActiveDirectoryManager];
GO
ALTER ROLE [ActiveDirectoryManager] ADD MEMBER [sa_ActiveDirectoryManager];
GO
-- Audit table
CREATE TABLE [ActiveDirectoryManagement].[AuditEmployeesDisabled] (
	[id] [int] IDENTITY(1,1) NOT NULL PRIMARY KEY,
	[Name] [nvarchar](6) NOT NULL,
	[Reason] nvarchar(max) NOT NULL,
	-- Disabled Markers
	[DateDisabled] datetime2 NOT NULL,
	[DisabledBy_Code] uniqueidentifier NOT NULL,
    [DisabledBy_Name] nvarchar(6) NOT NULL,
    [DisabledBy_Desc] nvarchar(max) NOT NULL,
	[DisabledDateProcessed] datetime2 NULL,
	-- Enabled Markers
	[DateEnabled] datetime2 NULL,
	[EnabledBy_Code] uniqueidentifier NOT NULL,
    [EnabledBy_Name] nvarchar(6) NOT NULL,
    [EnabledBy_Desc] nvarchar(max) NOT NULL,
	[EnabledProcessed] datetime2 NOT NULL,
	-- Processing Marker
	[Process] BIT DEFAULT(0) NOT NULL
);
GO
*/

-- Procedure to 
ALTER PROCEDURE [ActiveDirectoryManagement].[usp_Employee_GetProcessDisabled]
WITH EXECUTE AS OWNER
AS
BEGIN
	/**** 
		This procedure processes users disabled in LIFT via the checkbox
	****/
	SET NOCOUNT ON;

	-- Checking for disabled Employees and updating AuditList
	-- Joining the last modification of employees on audit table
	-- T = Target
	-- S = Source
	MERGE INTO [ActiveDirectoryManagement].[AuditEmployeesDisabled] T
	USING
		[ActiveDirectoryManagement].[EmployeesDisabled] S
	ON (T.[Name] = S.[Name] AND T.DateEnabled IS NULL)
	-- This is a new account to be disabled.
	WHEN NOT MATCHED BY TARGET THEN 
		INSERT ([Name],[Reason],[DateDisabled],[DisabledBy_Code],[DisabledBy_Name],[DisabledBy_Desc])
		VALUES (S.[Name],S.[Reason],S.[DateDisabled],S.[DisabledBy_Code],S.[DisabledBy_Name],S.[DisabledBy_Desc])
	
	;
	-- Accounts to be enabled
	UPDATE [ActiveDirectoryManagement].[AuditEmployeesDisabled]
	SET 
		[ActiveDirectoryManagement].[AuditEmployeesDisabled].[DateEnabled] = S.DateModified,
		[ActiveDirectoryManagement].[AuditEmployeesDisabled].[EnabledBy_Code] = S.ModifiedBy_Code,
		[ActiveDirectoryManagement].[AuditEmployeesDisabled].[EnabledBy_Name] = S.ModifiedBy_Name,
		[ActiveDirectoryManagement].[AuditEmployeesDisabled].[EnabledBy_Desc] = S.ModifiedBy_Desc
	FROM [ActiveDirectoryManagement].[AuditEmployeesDisabled] T
	INNER JOIN (
		SELECT 
			E.*
		FROM [ActiveDirectoryManagement].[AuditEmployeesDisabled] AED
		INNER JOIN [ActiveDirectoryManagement].[EmployeesAuditLastModified] E ON (E.[Name] = AED.[Name])
		WHERE AED.[Name] NOT IN (SELECT [Name] FROM [ActiveDirectoryManagement].[EmployeesDisabled])
	) S
	ON T.[Name] = S.[Name]

	-- Returning Records to be processed
	SELECT 
		 [Name]
		,[Disable]
		,[Reason] = CONCAT('Disabled by: ', [DisabledBy_Desc], ' @ ', DateDisabled, '. Reason: ', [Reason])
	FROM [ActiveDirectoryManagement].[AuditEmployeesDisabled]
	WHERE [Process] = 1
END

select * from [ActiveDirectoryManagement].[AuditEmployeesDisabled]

exec [ActiveDirectoryManagement].[usp_Employee_GetProcessDisabled]
GO

CREATE PROCEDURE [ActiveDirectoryManagement].[usp_Employee_UpdateProcessDisabled] (
	@Name nvarchar(6)
)
AS
BEGIN
	DECLARE @id INT = (SELECT MAX(id) FROM [ActiveDirectoryManagement].[AuditEmployeesDisabled] WHERE [name] = @Name)

	IF @id IS NOT NULL
	BEGIN
		IF (SELECT [Disable] FROM [ActiveDirectoryManagement].[AuditEmployeesDisabled] WHERE id = @id) = 0
		BEGIN
			UPDATE [ActiveDirectoryManagement].[AuditEmployeesDisabled] 
			SET [EnabledDateProcessed] = SYSUTCDATETIME()
			WHERE id = @id
		END
		ELSE
		BEGIN
			UPDATE [ActiveDirectoryManagement].[AuditEmployeesDisabled] 
			SET [DisabledDateProcessed] = SYSUTCDATETIME()
			WHERE id = @id
		END
	END
END