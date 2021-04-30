CREATE FUNCTION [setup].[TransformColumnNameAfas]
(
	@ColumnName nvarchar(100)
)
RETURNS table
AS
RETURN
(

WITH cte AS
(
-- Verwijder underscore aan het eind
SELECT ColumnName = CASE WHEN @ColumnName LIKE '%[_]' THEN LEFT(@ColumnName, LEN(@ColumnName)-1) ELSE @ColumnName END
)

-- Verwijder koppeltekens, punten en overbodige underscores
SELECT ColumnName = REPLACE(REPLACE(REPLACE(REPLACE(ColumnName,'-',''),'.',''),'__','_'),'__','_') FROM cte

)