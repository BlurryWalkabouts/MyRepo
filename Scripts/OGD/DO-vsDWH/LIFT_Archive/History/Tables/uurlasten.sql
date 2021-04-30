CREATE TABLE [History].[uurlasten] (
    [unid]                        UNIQUEIDENTIFIER NOT NULL,
    [tariefnaam]                  NVARCHAR (30)    NULL,
    [projectid]                   UNIQUEIDENTIFIER NULL,
    [looncomponent_declaratiesid] UNIQUEIDENTIFIER NULL,
    [tarief]                      MONEY            NULL,
    [grootboekid]                 UNIQUEIDENTIFIER NULL,
    [intern_tarief]               MONEY            NULL,
    [intern_grootboekid]          UNIQUEIDENTIFIER NULL,
    [is_kilometer]                BIT              NULL,
    [btwid]                       UNIQUEIDENTIFIER NULL,
    [end_date]                    DATETIME         NULL,
    [start_date]                  DATETIME         NULL,
    [AuditDWKey]              INT              NULL,
    [ValidFrom]                   DATETIME2 (0)    NOT NULL,
    [ValidTo]                     DATETIME2 (0)    NOT NULL
);



