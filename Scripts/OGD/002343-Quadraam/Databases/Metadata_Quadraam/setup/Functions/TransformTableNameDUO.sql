CREATE FUNCTION [setup].[TransformTableNameDUO]
(
	@TableName nvarchar(100)
)
RETURNS table
AS
RETURN
(

WITH cte1 AS
(
SELECT
	TableName = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName) > 0 THEN STUFF(@TableName,PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName),4,'') ELSE @TableName END
	, Connector = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName) > 0 THEN STUFF(@TableName,PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName),4,'%') ELSE @TableName END
	, Jaar1 = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName) > 0 THEN SUBSTRING(@TableName,PATINDEX('%[0-9][0-9][0-9][0-9]%',@TableName),4) ELSE NULL END
)

, cte2 AS
(
SELECT
	TableName = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',TableName) > 0 THEN STUFF(TableName,PATINDEX('%[0-9][0-9][0-9][0-9]%',TableName),4,'') ELSE TableName END
	, Connector = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',Connector) > 0 THEN STUFF(Connector,PATINDEX('%[0-9][0-9][0-9][0-9]%',Connector),4,'%') ELSE Connector END
	, Jaar1
	, Jaar2 = CASE WHEN PATINDEX('%[0-9][0-9][0-9][0-9]%',TableName) > 0 THEN SUBSTRING(TableName,PATINDEX('%[0-9][0-9][0-9][0-9]%',TableName),4) ELSE NULL END
FROM
	cte1
)

, cte3 AS
(
-- Verwijder koppeltekens, punten en overbodige underscores
SELECT
	TableName = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(STUFF(TableName,1,3,''),'-','_'),'_tov_',''),',',''),'(',''),')',''),'__','')
	, Connector = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(STUFF(Connector,1,3,'%'),'-','%'),'_tov_','%'),',','%'),'(','%'),')','%'),'__','%')
	, Jaar1
	, Jaar2 = CASE WHEN Jaar1 IS NOT NULL AND Jaar2 IS NULL THEN Jaar1 + 1 ELSE Jaar2 END
FROM
	cte2
)

, cte4 AS
(
-- Verwijder underscore aan het eind
SELECT
	TableName = CASE WHEN TableName LIKE '%[_]' THEN LEFT(TableName, LEN(TableName)-1) ELSE TableName END
	, Connector = REPLACE(REPLACE(REPLACE(Connector,'%%','%'),'%%','%'),'%%','%')
	, Jaar = CAST(Jaar1 AS char(4)) + '-' + CAST(Jaar2 AS char(4))
FROM
	cte3
)

SELECT
	TableName = CASE WHEN TableName LIKE '[_]%' THEN STUFF(TableName,1,1,'') ELSE TableName END
	, Connector
	, Jaar
FROM
	cte4
)