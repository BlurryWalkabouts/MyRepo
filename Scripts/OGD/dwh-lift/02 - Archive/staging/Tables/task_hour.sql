CREATE TABLE [Staging].[task_hour] (
    [seconds]    BIGINT           NULL,
    [old_amount] MONEY            NULL,
    [unid]       UNIQUEIDENTIFIER NULL,
    [dataanmk]   DATETIME         NULL,
    [datwijzig]  DATETIME         NULL,
    [uidaanmk]   UNIQUEIDENTIFIER NULL,
    [uidwijzig]  UNIQUEIDENTIFIER NULL,
    [datum]      DATETIME         NULL,
    [taskid]     UNIQUEIDENTIFIER NULL,
    [employeeid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL
);
