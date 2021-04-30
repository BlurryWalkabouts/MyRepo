CREATE TABLE [dbo].[documenttype] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [doccode2]           NVARCHAR (12)                                      NULL,
    [sjabloonnaam]       NVARCHAR (MAX)                                     NULL,
    [mailing]            BIT                                                NULL,
    [archiefid]          UNIQUEIDENTIFIER                                   NULL,
    [magimporteren]      BIT                                                NULL,
    [islastig]           BIT                                                NULL,
    [icoon]              NVARCHAR (20)                                      NULL,
    [archieficoon]       NVARCHAR (20)                                      NULL,
    [afkorting]          NVARCHAR (10)                                      NULL,
    [templateformat]     INT                                                NULL,
    [documentcategoryid] UNIQUEIDENTIFIER                                   NULL,
    [importonly]         BIT                                                NULL,
    [locale]             NVARCHAR (10)                                      NULL,
    [AuditDWKey]     INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbodocumenttypeSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbodocumenttypeSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbodocumenttype ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[documenttype], DATA_CONSISTENCY_CHECK=ON));

