CREATE TABLE [History].[report_custom_data] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [key]            NVARCHAR (100)   NULL,
    [data]           NVARCHAR (MAX)   NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

