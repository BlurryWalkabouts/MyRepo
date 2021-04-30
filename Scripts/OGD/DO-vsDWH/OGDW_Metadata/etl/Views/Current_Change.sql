-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Change viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_Change]
AS
SELECT
	*
FROM
	[$(OGDW_Archive)].etl.Point_Change(SYSDATETIME())