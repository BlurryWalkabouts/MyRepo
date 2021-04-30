CREATE TABLE [History].[uurtype] (
    [unid]                 UNIQUEIDENTIFIER NOT NULL,
    [projectid]            UNIQUEIDENTIFIER NULL,
    [looncomponent_urenid] UNIQUEIDENTIFIER NULL,
    [procent]              MONEY            NULL,
    [tariefnaam]           NVARCHAR (30)    NULL,
    [declarabel]           BIT              NULL,
    [end_date]             DATETIME         NULL,
    [start_date]           DATETIME         NULL,
    [AuditDWKey]           INT              NULL,
    [ValidFrom]            DATETIME2 (0)    NOT NULL,
    [ValidTo]              DATETIME2 (0)    NOT NULL
);

