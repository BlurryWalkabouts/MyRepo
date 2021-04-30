CREATE TABLE [dbo].[holiday_trading] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [dataanmk]       DATETIME                                           NULL,
    [datwijzig]      DATETIME                                           NULL,
    [uidaanmk]       UNIQUEIDENTIFIER                                   NULL,
    [uidwijzig]      UNIQUEIDENTIFIER                                   NULL,
    [employeeid]     UNIQUEIDENTIFIER                                   NULL,
    [note]           NVARCHAR(MAX)                                      NULL,
    [start_date]     DATETIME                                           NULL,
    [new_amount]     MONEY                                              NULL,
    [adjustment]     MONEY                                              NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboholiday_tradingSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboholiday_tradingSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboholiday_trading ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[holiday_trading], DATA_CONSISTENCY_CHECK=ON));

