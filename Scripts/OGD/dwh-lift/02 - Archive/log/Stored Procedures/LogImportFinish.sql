CREATE PROCEDURE [log].[LogImportFinish]
(
    @AuditDWKey int
)
WITH EXECUTE AS OWNER
AS
    SET NOCOUNT ON;

    UPDATE [log].[Audit]
    SET BatchEndDate = SYSDATETIME()
    WHERE [AuditDWKey] = @AuditDWKey;
    RETURN 0;
