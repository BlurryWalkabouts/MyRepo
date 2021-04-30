CREATE TABLE [History].[task_hour] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [old_amount]     MONEY            NULL,
    [datum]          DATETIME         NULL,
    [taskid]         UNIQUEIDENTIFIER NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [seconds]        BIGINT           NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);



