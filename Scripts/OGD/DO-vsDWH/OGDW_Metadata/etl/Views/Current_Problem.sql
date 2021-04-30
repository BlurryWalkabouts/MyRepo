-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Problem viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_Problem]
AS
SELECT
	*
FROM
	[$(OGDW_Archive)].etl.Point_Problem(SYSDATETIME())