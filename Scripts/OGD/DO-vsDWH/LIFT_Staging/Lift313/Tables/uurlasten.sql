CREATE TABLE [Lift313].[uurlasten] (
    [start_date]                  DATETIME         NULL,
    [end_date]                    DATETIME         NULL,
    [unid]                        UNIQUEIDENTIFIER NULL,
    [tariefnaam]                  NVARCHAR (30)    NULL,
    [projectid]                   UNIQUEIDENTIFIER NULL,
    [looncomponent_declaratiesid] UNIQUEIDENTIFIER NULL,
    [tarief]                      MONEY            NULL,
    [grootboekid]                 UNIQUEIDENTIFIER NULL,
    [intern_tarief]               MONEY            NULL,
    [intern_grootboekid]          UNIQUEIDENTIFIER NULL,
    [is_kilometer]                BIT              NULL,
    [btwid]                       UNIQUEIDENTIFIER NULL,
    [AuditDWKey]              INT              NULL
);

