CREATE TABLE [dbo].[checklistcustomerlink] (
    [unid]                       UNIQUEIDENTIFIER NOT NULL,
    [checkid]                    UNIQUEIDENTIFIER NULL,
    [customerid]                 UNIQUEIDENTIFIER NULL,
    [gebruikerid]                UNIQUEIDENTIFIER NULL,
    [gechecked]                  BIT              NULL,
    [dataanmk]                   DATETIME2(0)     NULL,
    [AuditDWKey]                 INT              NULL,
    [ValidFrom]  DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbochecklistcustomerlinkSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]    DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbochecklistcustomerlinkSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbochecklistcustomerlink] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[checklistcustomerlink], DATA_CONSISTENCY_CHECK=ON));