CREATE TABLE [Lift313].[report_configuration] (
    [unid]                  UNIQUEIDENTIFIER NULL,
    [dataanmk]              DATETIME         NULL,
    [datwijzig]             DATETIME         NULL,
    [uidaanmk]              UNIQUEIDENTIFIER NULL,
    [uidwijzig]             UNIQUEIDENTIFIER NULL,
    [custom_name]           NVARCHAR (100)   NULL,
    [configuration_data]    NVARCHAR (MAX)   NULL,
    [report_definition_key] INT              NULL,
    [table_card_code]       INT              NULL,
    [display_as]            INT              NULL,
    [AuditDWKey]        INT              NULL
);

