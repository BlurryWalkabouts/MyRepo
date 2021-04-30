CREATE TABLE [dbo].[grootboekrekening] (
    [unid]         UNIQUEIDENTIFIER                                   NOT NULL,
    [archief]      INT                                                NULL,
    [rang]         INT                                                NULL,
    [tekst]        NVARCHAR (10)                                      NULL,
    [omschrijving] NVARCHAR (30)                                      NULL,
    [kostendrager] NVARCHAR (25)                                      NULL,
    [kostenplaats] NVARCHAR (25)                                      NULL,
    [type]         INT                                                NULL,
    [belast]       BIT                                                NULL,
    [afkorting]    NVARCHAR (10)                                      NULL,
    [AuditDWKey]   INT                                                NULL,
    [ValidFrom]    DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_dbogrootboekrekeningSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]      DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_dbogrootboekrekeningSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_dbogrootboekrekening] PRIMARY KEY CLUSTERED ([unid] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[History].[grootboekrekening], DATA_CONSISTENCY_CHECK=ON));

