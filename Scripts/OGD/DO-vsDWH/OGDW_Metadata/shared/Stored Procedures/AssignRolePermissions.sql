CREATE PROCEDURE [shared].[AssignRolePermissions]
(
	@dbName nvarchar(64)
	, @debug bit = 0
)
AS

/*
This procedure grants or revokes select permission to the roles defined.
Roles will be created if they do not exist yet.

This procedure uses a table RolePermissions in schema shared. 
Use SP LoadPermissions to fill this table with data.

TODO:
- do not hardcode the login names, use table Roles instead
- only change the settings if current and new settings are different (if feasible)
- replace cursor by set-based solution (see SP AssignRolePermissions)
- use QUOTENAME instead of explicit []
- do not use the same Select statement 4 times, only to retrieve 4 different fields of the same record
	(note: declaring 4 variables is shifting the problem, not solving it; consider CTX or something like that)

*/

BEGIN

SET NOCOUNT ON

--	Walk through shared.RolePermissions.
--	Check setting and apply grant/revoke.
	
DECLARE db_cursor CURSOR FOR
(
SELECT
	SQLString = DatabaseName + '..sp_executesql N''' +
		CASE WHEN GrantSelect = 1 THEN 'GRANT' ELSE 'REVOKE' END + ' SELECT ' +
		'ON ' + DatabaseName + '.[' + SchemaName + '].[' + TableName + '] ([' + ColumnName + ']) ' +
		'TO [' + RoleName + '];'''
FROM
	shared.RolePermissions
WHERE 1=1
	AND DatabaseName = @dbName
)

DECLARE @SQLString nvarchar(max)

OPEN db_cursor
FETCH NEXT FROM db_cursor INTO @SQLString
WHILE @@FETCH_STATUS = 0
BEGIN
	IF @debug = 0 
		EXEC (@SQLString)
	ELSE
		PRINT @SQLString

	FETCH NEXT FROM db_cursor INTO @SQLString
END
CLOSE db_cursor
DEALLOCATE db_cursor

END