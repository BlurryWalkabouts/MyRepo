CREATE TABLE [dbo].[cursus] (
    [unid]           UNIQUEIDENTIFIER                                   NOT NULL,
    [werknemerid]    UNIQUEIDENTIFIER                                   NULL,
    [naam]           NVARCHAR (35)                                      NULL,
    [leverancier]    NVARCHAR (20)                                      NULL,
    [cursusdatum]    DATETIME                                           NULL,
    [einddatum]      DATETIME                                           NULL,
    [dagen]          INT                                                NULL,
    [diploma]        BIT                                                NULL,
    [AuditDWKey] INT                                                NULL,
    [ValidFrom]      DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbocursusSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]        DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbocursusSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbocursus ] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[cursus], DATA_CONSISTENCY_CHECK=ON));

