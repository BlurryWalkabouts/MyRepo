CREATE VIEW [setup].[vwColumnDefinition]
AS
SELECT
	DW.ID
	, DW.[Name]
	, DW.DWColumn
	, DW.Code
	, DW.DWFullType
	, DW.Import
	, DW.FI_DWSchema
	, DW.FI_StagingTableName
	, DW.FI_FullType
	, DW.FI_Type
	, DW.SSIS_type
	, DW.FI_SourceColumn
	, DW.TD_DWSchema
	, DW.TD_Type
	, DW.TD_FullType
	, DW.TD_Length
	, DW.TD_SourceTableName
	, DW.TD_SourceColumn
	, DW.TD_JoinKey
	, DW.TD_JoinForeignKey
	, DW.TD_JoinForeignTable
	, DW.Comment
/*
	, AM_import
	, AM_Schema
	, AM_AnchorName
	, AM_AnchorMnemonic
	, AM_AttributeName
	, AM_AttributeMnemonic
	, AM_KeyAttribute
	, AM_Historized
	, AM_Knotted
	, AM_KnotName
	, AM_KnotMnemonic
	, AM_Order
*/
FROM
	setup.DWColumnDefinition DW
--	LEFT OUTER JOIN setup.AMColumnDefinition AM ON DW.ID = AM.ID 
WHERE 1=1
--	AND DW.FI_StagingTableName IN ('Incidents', 'Changes')