CREATE PROCEDURE [etl].[GetMaxChangeDateFromStaging]
(
	@SourceDatabaseKey int
	, @SchemaName varchar(20)
	, @TableName varchar(50)
	, @debug bit = 0
)
AS
BEGIN

/*
Geeft laatste [datwijzig] van bijbehorende source terug
Alternatief is om deze waarden ergens op te slaan, maar voorlopig kost het zo ook heel weinig tijd en dit is veel zekerder 
(anders moet je de opgeslagen waarden ook aanpassen na het verwijderen van batches, etc)
*/

DECLARE @SQLString nvarchar(max) = '
SELECT
	MAXdatwijzig = CAST(COALESCE(MAX(datwijzig),''17530101'') AS datetime)
FROM
	[$(OGDW_Archive)].' + @SchemaName + '.' + @TableName + '
WHERE 1=1
	AND SourceDatabaseKey = ' + CAST(@SourceDatabaseKey AS char(4))

IF @debug = 0
	EXEC (@SQLString)
ELSE
	PRINT @SQLString

END

--EXEC etl.GetMaxChangeDateFromStaging 21,'TOPdesk','locatie'