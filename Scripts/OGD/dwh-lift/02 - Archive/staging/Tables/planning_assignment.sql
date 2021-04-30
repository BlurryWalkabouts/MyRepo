CREATE TABLE [Staging].[planning_assignment] (
    [unid]         UNIQUEIDENTIFIER NULL,
    [assignmentid] UNIQUEIDENTIFIER NULL,
    [startdate]    DATETIME         NULL,
	[enddate]    DATETIME           NULL,
    [amount]       INT              NULL,
    [AuditDWKey]   INT              NULL
);
