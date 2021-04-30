CREATE VIEW [setup].[DWColumnDefinition]
AS
SELECT
	ID
	, [Name]
	, DWColumn = [Name] -- Deze stond dubbel in mds, maar is inmiddels verwijderd. Er nog zijn verwijzingen naar beide versies.
	, Code
	, DWFullType
	, Import
	, FI_DWSchema = CASE WHEN ISNULL(FI_StagingTableName,'') <> '' THEN 'FileImport' ELSE '' END
	, FI_StagingTableName
	, FI_FullType
	, CASE WHEN CHARINDEX('(',FI_FullType, 0) > 0 THEN LEFT(FI_FullType, CHARINDEX('(',FI_FullType, 0)-1 ) ELSE FI_FullType END AS FI_Type
	, SSIS_type
	, FI_SourceColumn
	, TD_DWSchema
--	, TD_StagingColumn -- Deze wordt nergens gebruikt? mag uit MDS
	, TD_Type
	, TD_FullType = CASE WHEN TD_Length IS NOT NULL THEN TD_Type + ' (' + CAST(TD_Length AS varchar(4)) + ')' ELSE TD_Type END
	, TD_Length
	, TD_SourceTableName
	, TD_SourceColumn
	, TD_JoinKey
	, TD_JoinForeignKey
	, TD_JoinForeignTable
	, Comment
FROM
	[$(MDS)].mdm.DWColumnDefinition
WHERE 1=1
	AND Import = 1