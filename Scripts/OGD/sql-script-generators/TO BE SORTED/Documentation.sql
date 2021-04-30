-- ===================================================================================
-- Create Schema Template for Azure SQL Database and Azure SQL Data Warehouse Database
-- ===================================================================================

CREATE SCHEMA [Documentation];
GO

CREATE SCHEMA [Security];
GO

CREATE VIEW [Documentation].[vwTableRelationship] AS (
	SELECT   
	    [FromTableName] = CONCAT(OBJECT_SCHEMA_NAME(f.parent_object_id), '.', OBJECT_NAME(f.parent_object_id))
	   ,[FromColumnName] = COL_NAME(fc.parent_object_id, fc.parent_column_id) 
	   ,[ToTable] = CONCAT(OBJECT_SCHEMA_NAME(f.referenced_object_id), '.', OBJECT_NAME (f.referenced_object_id))
	   ,[ToColumnName] = COL_NAME(fc.referenced_object_id, fc.referenced_column_id)  
	   ,[RelationshipName] = f.name
	   ,[IsActive] = CASE WHEN is_disabled = 1 THEN 0 ELSE 1 END
	   ,[ActionOnDeleteInReferencedTable] = delete_referential_action_desc  
	   ,[ActionOnUpdateInReferencedTable] = update_referential_action_desc  
	FROM sys.foreign_keys AS f  
	INNER JOIN sys.foreign_key_columns AS fc   
	   ON f.object_id = fc.constraint_object_id
);
GO

CREATE VIEW [Security].[vwCustomerPermissions] AS (
	SELECT ADGroep = [name]
		  ,SQLRoleName = AG.[roleName]
		  ,[CustomerNumber] = C.DebitNumber
		  ,Fullname
		  ,G.OperatorGroup
	FROM [Security].[AzureGroup] AG
	LEFT JOIN [Security].AzureGroupMapping AGM ON (AGM.AzureGroupId = AG.Id)
	LEFT JOIN [Dim].[Customer] C ON (C.customerKey = AGM.CustomerKey)
	LEFT JOIN [Dim].[OperatorGroup] G ON (G.OperatorGroupKey = AGM.OperatorGroupKey)
);
GO

CREATE VIEW [Security].[vwLoginPermissions] AS (
	SELECT 
		 [DatabaseRoleName] = DP1.name
		,[DatabaseUserName] = COALESCE(DP2.name, 'No members')
		,[DatabaseUserType] = 
		CASE DP2.[Type]
			WHEN 'A' THEN 'Application role'
			WHEN 'C' THEN 'User mapped to a certificate'
			WHEN 'E' THEN 'External user from Azure Active Directory'
			WHEN 'G' THEN 'Windows group'
			WHEN 'K' THEN 'User mapped to an asymmetric key'
			WHEN 'R' THEN 'Database role'
			WHEN 'S' THEN 'SQL user'
			WHEN 'U' THEN 'Windows user'
			WHEN 'X' THEN 'External group from Azure Active Directory group or applications'
			ELSE COALESCE(DP2.Type_Desc, 'No type')
		END
	 FROM sys.database_role_members AS DRM  
	 RIGHT OUTER JOIN sys.database_principals AS DP1  
	   ON DRM.role_principal_id = DP1.principal_id  
	 LEFT OUTER JOIN sys.database_principals AS DP2  
	   ON DRM.member_principal_id = DP2.principal_id  
	 WHERE DP1.type = 'R'
)
GO

CREATE VIEW [Security].[vwTablePermissions] AS (
	--List all access provisioned to a sql user or windows user/group through a database or application role
	-- Based on: https://stackoverflow.com/questions/7048839/sql-server-query-to-find-all-permissions-access-for-all-users-in-a-database
	SELECT  
		[DatabaseUserName] = memberprinc.[name],
		[DatabaseUserType] = CASE memberprinc.[type]
				WHEN 'A' THEN 'Application role'
				WHEN 'C' THEN 'User mapped to a certificate'
				WHEN 'E' THEN 'External user from Azure Active Directory'
				WHEN 'G' THEN 'Windows group'
				WHEN 'K' THEN 'User mapped to an asymmetric key'
				WHEN 'R' THEN 'Database role'
				WHEN 'S' THEN 'SQL user'
				WHEN 'U' THEN 'Windows user'
				WHEN 'X' THEN 'External group from Azure Active Directory group or applications'
					 END, 
		[DatabaseRoleName] = roleprinc.[name],      
		[PermissionType] = CASE roleprinc.[name]
			WHEN 'db_datareader' THEN 'SELECT'
			WHEN 'db_owner' THEN 'ALL'
			WHEN 'db_datawriter' THEN 'INSERT, UPDATE, DELETE'
			ELSE perm.[permission_name]
		END,     
		[PermissionState] = CASE 
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN 'GRANT' 
			ELSE perm.[state_desc]
		END,       
		[ObjectType] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL TYPES}' 
			ELSE obj.type_desc
		END,   
		[ObjectName] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL OBJECTS}' 
			ELSE OBJECT_NAME(perm.major_id)
		END,
		[ColumnName] = CASE
			WHEN roleprinc.[name] IN ('db_datareader', 'db_owner', 'db_datawriter') THEN '{ALL COLUMNS}' 
			ELSE col.[name]
		END
	FROM    
		--Role/member associations
		sys.database_role_members members
	JOIN
		--Roles
		sys.database_principals roleprinc ON roleprinc.[principal_id] = members.[role_principal_id]
	JOIN
		--Role members (database users)
		sys.database_principals memberprinc ON memberprinc.[principal_id] = members.[member_principal_id]
	LEFT JOIN        
		--Permissions
		sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN
		--Table columns
		sys.columns col on col.[object_id] = perm.major_id 
						AND col.[column_id] = perm.[minor_id]
	LEFT JOIN
		sys.objects obj ON perm.[major_id] = obj.[object_id]
	UNION
	--List all access provisioned to the public role, which everyone gets by default
	SELECT  
		[UserName] = '{All Users}',
		[UserType] = '{All Users}',     
		[RoleName] = roleprinc.[name],      
		[PermissionType] = perm.[permission_name],       
		[PermissionState] = perm.[state_desc],       
		[ObjectType] = obj.type_desc,--perm.[class_desc],  
		[ObjectName] = OBJECT_NAME(perm.major_id),
		[ColumnName] = col.[name]
	FROM    
		--Roles
		sys.database_principals roleprinc
	LEFT JOIN        
		--Role permissions
		sys.database_permissions perm ON perm.[grantee_principal_id] = roleprinc.[principal_id]
	LEFT JOIN
		--Table columns
		sys.columns col on col.[object_id] = perm.major_id 
						AND col.[column_id] = perm.[minor_id]                   
	JOIN 
		--All objects   
		sys.objects obj ON obj.[object_id] = perm.[major_id]
	WHERE
		--Only roles
		roleprinc.[type] = 'R' AND
		--Only public role
		roleprinc.[name] = 'public' AND
		--Only objects of ours, not the MS objects
		obj.is_ms_shipped = 0
		/*
	ORDER BY
		DatabaseUserType,
		DataabaseUserName,
		PermissionType,
		PermissionState,
		ObjectType,
		ObjectName,
		ColumnName
		*/
)
GO

CREATE USER [member-ogd-medewerkers] FROM EXTERNAL PROVIDER;
GO

CREATE ROLE [Documentation];
GO
GRANT SELECT ON SCHEMA::DOCUMENTATION TO [Documentation];
GO
GRANT SELECT ON [Security].[vwLoginPermissions] TO [Documentation];
GO
GRANT SELECT ON [Security].[vwTablePermissions] TO [Documentation];
GO
GRANT SELECT ON [Security].[vwCustomerPermissions] TO [Documentation];
GO
ALTER ROLE [Documentation] ADD MEMBER [member-ogd-medewerkers];
GO