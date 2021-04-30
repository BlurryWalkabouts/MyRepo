CREATE TABLE [Lift313].[registration_assignment_log] (
    [unid]                UNIQUEIDENTIFIER NULL,
    [dataanmk]            DATETIME         NULL,
    [datwijzig]           DATETIME         NULL,
    [uidaanmk]            UNIQUEIDENTIFIER NULL,
    [uidwijzig]           UNIQUEIDENTIFIER NULL,
    [submit_date]         DATETIME         NULL,
    [submit_date_cleared] BIT              NULL,
    [accept_date]         DATETIME         NULL,
    [accept_date_cleared] BIT              NULL,
    [assignmentid]        UNIQUEIDENTIFIER NULL,
    [changing_process]    INT              NULL,
    [AuditDWKey]      INT              NULL
);

