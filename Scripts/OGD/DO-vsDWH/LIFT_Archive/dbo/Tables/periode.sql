CREATE TABLE [dbo].[periode] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [archief]        INT                                                NULL,
    [rang]           INT                                                NULL,
    [tekst]          NVARCHAR (15)                                      NULL,
    [meervoud]       NVARCHAR (15)                                      NULL,
    [type]           INT                                                NULL,
    [aantal]         MONEY                                              NULL,
    [afkorting]      NVARCHAR (10)                                      NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dboperiodeSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dboperiodeSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dboperiode ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[periode], DATA_CONSISTENCY_CHECK=ON));

