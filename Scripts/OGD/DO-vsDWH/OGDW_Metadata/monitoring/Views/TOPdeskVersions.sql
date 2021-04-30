CREATE VIEW [monitoring].[TOPdeskVersions]
AS

SELECT
	SourceDatabaseKey
	, product
	, build
	, [version]
	, AuditDWKey
	, ValidFrom
FROM
	[$(OGDW_Archive)].TOPdesk.[version]