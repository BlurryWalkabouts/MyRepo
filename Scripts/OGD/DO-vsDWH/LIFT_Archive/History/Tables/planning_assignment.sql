CREATE TABLE [History].[planning_assignment] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [assignmentid]   UNIQUEIDENTIFIER NULL,
    [startdate]      DATETIME         NULL,
    [amount]         INT              NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

