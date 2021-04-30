CREATE TABLE [History].[planning_task_assignment] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [task_assignmentid] UNIQUEIDENTIFIER NULL,
    [startdate]         DATETIME         NULL,
    [amount]            INT              NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);

