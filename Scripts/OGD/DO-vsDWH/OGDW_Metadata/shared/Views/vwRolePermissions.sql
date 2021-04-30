CREATE VIEW [shared].[vwRolePermissions]
AS

-- De namen van de rollen zijn (nog) hardgecodeerd, net als in LoadRolePermissions
SELECT
	DatabaseName
	, SchemaName
	, TableName
	, ColumnName
	, Finance
	, HumanResources
	, Operations
	, Coordinatie
	, BBHDashboard
FROM
	(SELECT DatabaseName, SchemaName, TableName, ColumnName, GrantSelect, RoleName FROM shared.RolePermissions) x
	PIVOT (MAX(GrantSelect) FOR RoleName IN (Finance, HumanResources, Operations, Coordinatie, BBHDashboard)) y