CREATE PROCEDURE [log].[LogImportStart]
(
    @AuditDWKey int  = NULL OUTPUT
)
WITH EXECUTE AS OWNER
AS
    SET NOCOUNT ON;

    INSERT INTO
        [log].[Audit] (DateImported, BatchStartDate, BatchEndDate)
    VALUES
        (NULL, SYSDATETIME(), NULL);

    SET @AuditDWKey = SCOPE_IDENTITY();
    SELECT [AuditDWKey] = @AuditDWKey;
    RETURN 0;
