CREATE VIEW [Load].[vwRolePermissions]
AS

-- De namen van de rollen zijn (nog) hardgecodeerd, net als in LoadRolePermissions
SELECT
	SchemaName
	, TableName
	, ColumnName
	, Finance
	, HumanResources
	, Operations
	, Coordinatie
	, BBHDashboard
FROM
	(SELECT SchemaName, TableName, ColumnName, GrantSelect, RoleName FROM [Load].RolePermissions) x
	PIVOT (MAX(GrantSelect) FOR RoleName IN (Finance, HumanResources, Operations, Coordinatie, BBHDashboard)) y