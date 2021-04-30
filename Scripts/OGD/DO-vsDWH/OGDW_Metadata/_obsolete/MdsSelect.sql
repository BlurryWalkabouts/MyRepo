CREATE PROCEDURE [setup].[MdsSelect]
(
	@mdsViewName nvarchar(max)
	, @dimTableFullName nvarchar(max)
	, @SQL nvarchar(max) OUTPUT
)
AS
BEGIN

-- =============================================
-- Author:		Mark Versteegh
-- Create date: 20141111
-- Description:	creates select-query from mds-view
--20161109 MV: verplaatst naar OGDW_metadata
-- =============================================

SET NOCOUNT ON

;WITH cte(column_name) AS
(
SELECT
	N', ' + CASE WHEN CHARINDEX('_Name',c.[name]) > 0 THEN REPLACE(c.[name],'_Name','') + ' = ' ELSE '' END + c.[name]
FROM
	[$(MDS)].sys.views v 
	INNER JOIN [$(MDS)].sys.schemas s ON v.[schema_id] = s.[schema_id]
	INNER JOIN [$(MDS)].sys.columns c ON v.[object_id] = c.[object_id]
WHERE 1=1
	AND v.[name] = @mdsViewName
	AND s.[name] = 'mdm'
	-- List of columns to ignore:
	AND c.[name] NOT IN ('Version_ID', 'ID', 'Name', 'MUID', 'VersionName', 'VersionNumber', 'VersionFlag', 'ChangeTrackingMask'
		, 'EnterDateTime', 'EnterUserName', 'EnterVersionNumber', 'LastChgDateTime', 'LastChgUserName', 'LastChgVersionNumber'
		, 'ValidationStatus')
ORDER BY
	c.column_id	FOR XML PATH (''), TYPE
)

-- Re-create table, using the column-definitions from the mds-view, ignoring the status-columns added by mds.
SELECT @SQL = N'
SELECT
	' + STUFF((SELECT column_name FROM cte).value('text()[1]','nvarchar(max)'), 1, 2, N'') + '
INTO' + '
	' + @dimTableFullname + '
FROM
	MDS.mdm.' + @mdsViewName

RETURN

END