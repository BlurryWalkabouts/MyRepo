CREATE EXTERNAL TABLE [archive].[wcontract] (
    [unid]                         uniqueidentifier                                  NOT NULL,
    [dataanmk]                     datetime                                          NULL,
    [datwijzig]                    datetime                                          NULL,
    [status]                       int                                               NULL,
    [werknemerid]                  uniqueidentifier                                  NULL,
    [procent]                      money                                             NULL,
    [contractsoort]                nvarchar(30)                                      NULL,
    [startdatum]                   datetime                                          NULL,
    [einddatum]                    datetime                                          NULL,
    [uurtarief]                    money                                             NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'wcontract'
);
