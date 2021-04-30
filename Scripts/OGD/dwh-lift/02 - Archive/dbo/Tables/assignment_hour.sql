CREATE TABLE [dbo].[assignment_hour] (
    [unid]               UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]           DATETIME                                           NULL,
    [datwijzig]          DATETIME                                           NULL,
    [uidaanmk]           UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]          UNIQUEIDENTIFIER                                   NULL,
    [old_amount]         MONEY                                              NULL,
    [datum]              DATETIME                                           NULL,
    [verwerkt_factuur]   BIT                                                NULL,
    [factuurid]          UNIQUEIDENTIFIER                                   NULL,
    [seen_by_invoice_id] UNIQUEIDENTIFIER                                   NULL,
    [hourtypeid]         UNIQUEIDENTIFIER                                   NULL,
    [assignmentid]       UNIQUEIDENTIFIER                                   NULL,
    [seconds]            BIGINT                                             NULL,
    [AuditDWKey]         INT                                                NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboassignment_hourSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboassignment_hourSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboassignment_hour] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[assignment_hour], DATA_CONSISTENCY_CHECK=ON));

