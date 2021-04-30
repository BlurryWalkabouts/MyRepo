CREATE TABLE [History].[werknemer_activiteitgroep_link] (
    [unid]               UNIQUEIDENTIFIER  NOT NULL,
    [werknemerid]        UNIQUEIDENTIFIER  NULL,
    [activiteitgroepid]  UNIQUEIDENTIFIER  NULL,
    [AuditDWKey]         INT               NULL,
    [ValidFrom]          DATETIME2(0)      NOT NULL,
    [ValidTo]            DATETIME2(0)      NOT NULL
);
