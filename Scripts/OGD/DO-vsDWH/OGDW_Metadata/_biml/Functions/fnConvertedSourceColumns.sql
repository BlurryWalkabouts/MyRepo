CREATE FUNCTION [setup].[fnConvertedSourceColumns]
(	
	@SourceDatabaseDWKey int
	, @DWStagingTableName varchar(50)
)
RETURNS TABLE
AS
RETURN

-- =============================================
-- Author:    Mark Versteegh
-- Create date: 20141215
-- Description: wordt gebruikt in CreateLoadStagingPackage.biml
-- TODO: afwijkende kolommen TD5.2 afhandelen
--=============================================

WITH target_columns AS
(
SELECT
	TableName = cd.TableName
	, SourceColumn = cd.SourceColumn
	, TargetDataType = cd.TargetDataType
	, TargetCharMaxLen = cd.TargetCharMaxLen
	, TargetNumPrec = cd.TargetNumPrec
	, TargetNumScale = cd.TargetNumScale
	, TargetIsNullable = cd.TargetIsNullable
	, CastToSSIS = t.CastToSSIS
	, TargetBimlType = t.BimlType
FROM
	setup.DBImportColumnDefintion cd
	INNER JOIN setup.SSISTypes t ON cd.TargetDataType = t.SqlType
)

, source_columns AS
(
SELECT
	DataType = m.DataType
	, CharacterLength = m.CharacterLength
	, NumericPrecision = m.NumericPrecision
	, NumericScale = m.NumericScale
	, ColumnName = m.ColumnName
	, TableName = m.TableName
	, SourceDatabaseDWKey = m.SourceDatabaseDWKey
	, IsNullable = m.IsNullable
	, BimlType = t.BimlType
FROM
	TOPdesk4.Metadata m
	INNER JOIN setup.SSISTypes t ON m.DataType = t.SqlType
WHERE 1=1
	AND SourceDatabaseDWKey = @SourceDatabaseDWKey
)

SELECT DISTINCT
	TableName = tc.TableName
--	, s.ColumnName
	, SourceColumn = tc.SourceColumn
	, ConversionSourceColumn = CASE
			WHEN tc.TargetDataType <> sc.DataType
			THEN 'CONVERT(' + tc.TargetDataType + CASE
					WHEN tc.TargetCharMaxLen IS NOT NULL THEN '(' + CONVERT(nvarchar(10),tc.TargetCharMaxLen) + ')'
					ELSE ''
				END  + ',[' + tc.SourceColumn + ']) as [' + tc.SourceColumn + ']'
			-- Uitzondering voor TD5.2, waar de kolom [adjustedduration] is vervangen door de kolommen [adjusteddurationonhold] en [adjusteddurationresolved]
			WHEN tc.SourceColumn = 'adjustedduration' THEN 'adjusteddurationonhold AS adjustedduration'
			ELSE tc.SourceColumn
		END
  , SourceDataType = sc.DataType
  , TargetDataType = tc.TargetDataType
FROM
	target_columns tc
	LEFT OUTER JOIN source_columns sc ON tc.TableName = sc.TableName AND tc.SourceColumn = REPLACE(sc.ColumnName,'adjusteddurationonhold','adjustedduration')
WHERE 1=1
	AND tc.TableName = @DWStagingTableName