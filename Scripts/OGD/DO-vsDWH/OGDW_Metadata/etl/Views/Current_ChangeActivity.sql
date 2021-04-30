-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_ChangeActivity viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_ChangeActivity]
AS
SELECT
	*
FROM
	[$(OGDW_Archive)].etl.Point_ChangeActivity(SYSDATETIME())