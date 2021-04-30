CREATE TABLE [History].[planning_coworker_availability] (
    [unid]       UNIQUEIDENTIFIER NOT NULL,
    [coworkerid] UNIQUEIDENTIFIER NULL,
    [startdate]  DATETIME         NULL,
    [amount]     INT              NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]  DATETIME2 (0)    NOT NULL,
    [ValidTo]    DATETIME2 (0)    NOT NULL
);

