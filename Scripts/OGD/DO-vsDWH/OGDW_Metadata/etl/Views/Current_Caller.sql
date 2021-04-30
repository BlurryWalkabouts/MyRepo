-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Caller viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_Caller]
AS
SELECT
	*
FROM
	etl.Point_Caller(SYSDATETIME())