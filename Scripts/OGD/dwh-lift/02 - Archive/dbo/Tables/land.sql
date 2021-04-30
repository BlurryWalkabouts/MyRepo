CREATE TABLE [dbo].[land] (
    [unid]            UNIQUEIDENTIFIER                                   NOT NULL,
    [archief]         INT                                                NULL,
    [rang]            INT                                                NULL,
    [landnaam]        NVARCHAR (50)                                      NULL,
    [exactcode]       NVARCHAR (10)                                      NULL,
    [afascode]        NVARCHAR (10)                                      NULL,
    [kingcode]        NVARCHAR (10)                                      NULL,
    [pclengte]        INT                                                NULL,
    [nummereerst]     BIT                                                NULL,
    [nummerverplicht] BIT                                                NULL,
    [voertaalid]      UNIQUEIDENTIFIER                                   NULL,
    [adrescontrole]   BIT                                                NULL,
    [afkorting]       NVARCHAR (10)                                      NULL,
    [AuditDWKey]      INT                                                NULL,
    [ValidFrom]       DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbolandSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]         DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbolandSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboland] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[land], DATA_CONSISTENCY_CHECK=ON));

