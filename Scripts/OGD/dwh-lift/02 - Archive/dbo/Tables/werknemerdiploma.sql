CREATE TABLE [dbo].[werknemerdiploma] (
    [unid]            UNIQUEIDENTIFIER                                   NOT NULL,
    [werknemerid]     UNIQUEIDENTIFIER                                   NULL,
    [diplomaid]       UNIQUEIDENTIFIER                                   NULL,
    [diploma]         NVARCHAR (25)                                      NULL,
    [expiration_date] DATETIME                                           NULL,
    [AuditDWKey]      INT                                                NULL,
    [ValidFrom]       DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbowerknemerdiplomaSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]         DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbowerknemerdiplomaSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbowerknemerdiploma] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[werknemerdiploma], DATA_CONSISTENCY_CHECK=ON));

