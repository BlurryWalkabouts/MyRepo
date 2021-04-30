CREATE PROCEDURE [dbo].[CheckMetadataNrOfMissingColumns]
(
	@SourceDatabaseDWKey int
	, @AuditDWKey int
	-- Incidents of changes, deze parameter krijgt nu een verkeerde waarde mee vanuit de packages; we doen er verder toch niets meer mee, maar
	-- laten het toch staan, zodat we niet alle packages opnieuw hoeven aan te maken; TODO: verwijzing uit package halen
	, @SourceFileType nvarchar(20)
	, @NrOfMissingColumns int OUTPUT
)
AS
BEGIN

SELECT
	@NrOfMissingColumns = COUNT(ExpectedColumns)
FROM
	monitoring.CheckMissingColumns(@SourceDatabaseDWKey, @AuditDWKey)

END

/*
DECLARE @NrOfMissingColumns int

EXEC dbo.CheckMetadataNrOfMissingColumns
	@SourceDatabaseDWKey = 49
	, @AuditDWKey = 10240
	, @SourceFileType = 'Incidents'
	, @NrOfMissingColumns = @NrOfMissingColumns OUTPUT

PRINT @NrOfMissingColumns
*/