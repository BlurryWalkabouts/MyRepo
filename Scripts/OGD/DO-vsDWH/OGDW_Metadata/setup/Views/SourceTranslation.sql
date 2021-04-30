CREATE VIEW [setup].[SourceTranslation]
AS
SELECT
	ID
	, [Name]
	, Code
	, SourceName
	, DWTableName
	, DWColumnName = DWColumnName_Name
	, DWColumnName_Code 
	, AMAnchorName
	, TranslatedColumnName
	, SourceValue = ISNULL(SourceValue,'') -- 20151116 aangepast vanwege blanco-waarden die vertaald moeten worden naar Geen 
	, TranslatedValue
	, TranslationType_Code
	, TranslationType_Name
FROM
	[$(MDS)].mdm.SourceTranslation