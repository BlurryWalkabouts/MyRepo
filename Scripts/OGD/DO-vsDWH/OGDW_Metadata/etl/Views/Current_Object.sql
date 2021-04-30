-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Object viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_Object]
AS
SELECT
	*
FROM
	etl.Point_Object(SYSDATETIME())