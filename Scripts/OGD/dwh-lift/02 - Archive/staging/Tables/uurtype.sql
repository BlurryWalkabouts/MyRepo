CREATE TABLE [Staging].[uurtype] (
    [start_date]           DATETIME         NULL,
    [end_date]             DATETIME         NULL,
    [unid]                 UNIQUEIDENTIFIER NULL,
    [projectid]            UNIQUEIDENTIFIER NULL,
    [looncomponent_urenid] UNIQUEIDENTIFIER NULL,
    [procent]              MONEY            NULL,
    [tariefnaam]           NVARCHAR (30)    NULL,
    [declarabel]           BIT              NULL,
    [AuditDWKey]           INT              NULL
);
