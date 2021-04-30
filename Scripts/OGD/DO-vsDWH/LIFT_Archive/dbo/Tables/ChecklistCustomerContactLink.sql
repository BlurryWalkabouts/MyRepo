CREATE TABLE [dbo].[ChecklistCustomerContactLink] (
    [unid]              UNIQUEIDENTIFIER                                   NOT NULL,
    [checkid]           UNIQUEIDENTIFIER                                   NULL,
    [customercontactid] UNIQUEIDENTIFIER                                   NULL,
    [gebruikerid]       UNIQUEIDENTIFIER                                   NULL,
    [gechecked]         BIT                                                NULL,
    [dataanmk]          DATETIME                                           NULL,
    [extra_info]        NVARCHAR (MAX)                                     NULL,
    [AuditDWKey]    INT                                                NULL,
    [ValidFrom]         DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboChecklistCustomerContactLinkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]           DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboChecklistCustomerContactLinkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboChecklistCustomerContactLink ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[ChecklistCustomerContactLink], DATA_CONSISTENCY_CHECK=ON));

