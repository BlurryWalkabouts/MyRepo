CREATE TABLE [dbo].[kennisitemdeluxe] (
    [archief]        INT                                                NULL,
    [rang]           INT                                                NULL,
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [tekst]          NVARCHAR (40)                                      NULL,
    [parentid]       UNIQUEIDENTIFIER                                   NULL,
    [type]           INT                                                NULL,
    [afkorting]      NVARCHAR (10)                                      NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbokennisitemdeluxeSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbokennisitemdeluxeSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbokennisitemdeluxe ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[kennisitemdeluxe], DATA_CONSISTENCY_CHECK=ON));

