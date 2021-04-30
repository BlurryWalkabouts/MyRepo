CREATE EXTERNAL TABLE [archive].[verantwoording] (
    [unid]       uniqueidentifier                                  NOT NULL,
    [tekst]      nvarchar(20)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'verantwoording'
);
