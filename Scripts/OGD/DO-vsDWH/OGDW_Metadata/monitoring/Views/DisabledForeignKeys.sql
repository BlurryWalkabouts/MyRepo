CREATE VIEW [monitoring].[DisabledForeignKeys]
AS

SELECT
	DbName
	, DisableDate
	, ForeignKey
FROM
	shared.ForeignKeys