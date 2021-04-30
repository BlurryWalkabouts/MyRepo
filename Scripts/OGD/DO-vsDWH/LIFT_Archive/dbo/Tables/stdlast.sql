CREATE TABLE [dbo].[stdlast] (
    [unid]                        UNIQUEIDENTIFIER                                   NOT NULL,
    [archief]                     INT                                                NULL,
    [rang]                        INT                                                NULL,
    [tariefnaam]                  NVARCHAR (30)                                      NULL,
    [tarief]                      MONEY                                              NULL,
    [intern_tarief]               MONEY                                              NULL,
    [looncomponent_declaratiesid] UNIQUEIDENTIFIER                                   NULL,
    [is_kilometer]                BIT                                                NULL,
    [grootboekid]                 UNIQUEIDENTIFIER                                   NULL,
    [intern_grootboekid]          UNIQUEIDENTIFIER                                   NULL,
    [btwid]                       UNIQUEIDENTIFIER                                   NULL,
    [afkorting]                   NVARCHAR (10)                                      NULL,
    [AuditDWKey]              INT                                                NULL,
    [ValidFrom]                   DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbostdlastSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]                     DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbostdlastSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbostdlast ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[stdlast], DATA_CONSISTENCY_CHECK=ON));

