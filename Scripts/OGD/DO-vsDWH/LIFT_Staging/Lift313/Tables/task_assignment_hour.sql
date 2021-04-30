CREATE TABLE [Lift313].[task_assignment_hour] (
    [seconds]           BIGINT           NULL,
    [old_amount]        MONEY            NULL,
    [unid]              UNIQUEIDENTIFIER NULL,
    [dataanmk]          DATETIME         NULL,
    [datwijzig]         DATETIME         NULL,
    [uidaanmk]          UNIQUEIDENTIFIER NULL,
    [uidwijzig]         UNIQUEIDENTIFIER NULL,
    [datum]             DATETIME         NULL,
    [aantekeningen]     NVARCHAR (MAX)   NULL,
    [task_assignmentid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]    INT              NULL
);

