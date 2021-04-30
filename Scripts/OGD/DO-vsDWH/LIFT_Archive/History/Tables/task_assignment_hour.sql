CREATE TABLE [History].[task_assignment_hour] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]          DATETIME         NULL,
    [datwijzig]         DATETIME         NULL,
    [uidaanmk]          UNIQUEIDENTIFIER NULL,
    [uidwijzig]         UNIQUEIDENTIFIER NULL,
    [old_amount]        MONEY            NULL,
    [datum]             DATETIME         NULL,
    [aantekeningen]     NVARCHAR (MAX)   NULL,
    [task_assignmentid] UNIQUEIDENTIFIER NULL,
    [seconds]           BIGINT           NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);



