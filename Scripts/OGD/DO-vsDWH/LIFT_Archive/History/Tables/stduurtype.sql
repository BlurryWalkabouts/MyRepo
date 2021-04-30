CREATE TABLE [History].[stduurtype] (
    [unid]                 UNIQUEIDENTIFIER NOT NULL,
    [archief]              INT              NULL,
    [rang]                 INT              NULL,
    [looncomponent_urenid] UNIQUEIDENTIFIER NULL,
    [afkorting]            NVARCHAR (10)    NULL,
    [procent]              MONEY            NULL,
    [tariefnaam]           NVARCHAR (30)    NULL,
    [declarabel]           BIT              NULL,
    [AuditDWKey]       INT              NULL,
    [ValidFrom]            DATETIME2 (0)    NOT NULL,
    [ValidTo]              DATETIME2 (0)    NOT NULL
);

