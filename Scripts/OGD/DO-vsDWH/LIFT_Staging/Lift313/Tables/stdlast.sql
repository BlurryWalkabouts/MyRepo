CREATE TABLE [Lift313].[stdlast] (
    [unid]                        UNIQUEIDENTIFIER NULL,
    [archief]                     INT              NULL,
    [rang]                        INT              NULL,
    [tariefnaam]                  NVARCHAR (30)    NULL,
    [tarief]                      MONEY            NULL,
    [intern_tarief]               MONEY            NULL,
    [looncomponent_declaratiesid] UNIQUEIDENTIFIER NULL,
    [is_kilometer]                BIT              NULL,
    [grootboekid]                 UNIQUEIDENTIFIER NULL,
    [intern_grootboekid]          UNIQUEIDENTIFIER NULL,
    [btwid]                       UNIQUEIDENTIFIER NULL,
    [afkorting]                   NVARCHAR (10)    NULL,
    [AuditDWKey]              INT              NULL
);

