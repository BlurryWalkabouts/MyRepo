CREATE TABLE [History].[invoice_reminder_plan] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [archief]        INT              NULL,
    [rang]           INT              NULL,
    [name]           NVARCHAR (30)    NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

