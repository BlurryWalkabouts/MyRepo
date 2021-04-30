CREATE TABLE [Staging].[planning_task_assignment] (
    [unid]              UNIQUEIDENTIFIER NULL,
    [task_assignmentid] UNIQUEIDENTIFIER NULL,
    [startdate]         DATETIME         NULL,
	[enddate]           DATETIME         NULL,
    [amount]            INT              NULL,
    [AuditDWKey]        INT              NULL
);
