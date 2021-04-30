-- Now perspective ----------------------------------------------------------------------------------------------------
-- Current_Incident viewed as it currently is (cannot include future versions)
-----------------------------------------------------------------------------------------------------------------------
CREATE VIEW [etl].[Current_Incident]
AS
SELECT
	*
FROM
	[$(OGDW_Archive)].etl.Point_Incident(SYSDATETIME())