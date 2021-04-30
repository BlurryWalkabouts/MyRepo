CREATE TABLE [dbo].[betalingsconditie] (
    [unid]               UNIQUEIDENTIFIER     NOT NULL,
    [rang]               INT                  NULL,
    [vervaltermijn]      INT                  NULL,
    [AuditDWKey]         INT                  NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbobetalingsconditieSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbobetalingsconditieSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbobetalingsconditie] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[betalingsconditie], DATA_CONSISTENCY_CHECK=ON));