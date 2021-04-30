CREATE TABLE [History].[external_registration_hour] (
    [unid]                       UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]                   DATETIME         NULL,
    [datwijzig]                  DATETIME         NULL,
    [uidaanmk]                   UNIQUEIDENTIFIER NULL,
    [uidwijzig]                  UNIQUEIDENTIFIER NULL,
    [employeeid]                 UNIQUEIDENTIFIER NULL,
    [external_registrationid]    UNIQUEIDENTIFIER NULL,
    [hourtype_name]              NVARCHAR (30)    NULL,
    [hourtype_billable]          BIT              NULL,
    [hourtype_percent]           MONEY            NULL,
    [date]                       DATETIME         NULL,
    [seconds]                    BIGINT           NULL,
    [notes]                      NVARCHAR (MAX)   NULL,
    [assignment_hourtype_linkid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]             INT              NULL,
    [ValidFrom]                  DATETIME2 (0)    NOT NULL,
    [ValidTo]                    DATETIME2 (0)    NOT NULL
);

