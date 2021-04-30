CREATE TABLE [History].[holiday_trading] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [note]           NVARCHAR(MAX)    NULL,
    [start_date]     DATETIME         NULL,
    [new_amount]     MONEY            NULL,
    [adjustment]     MONEY            NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);



