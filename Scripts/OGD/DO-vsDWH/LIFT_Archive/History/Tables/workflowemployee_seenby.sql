CREATE TABLE [History].[workflowemployee_seenby] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [workflowid]     UNIQUEIDENTIFIER NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

