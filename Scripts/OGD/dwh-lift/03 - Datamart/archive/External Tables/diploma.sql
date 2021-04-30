CREATE EXTERNAL TABLE [archive].[diploma] (
    [unid]       uniqueidentifier                                  NOT NULL,
    [tekst]      nvarchar(25)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'diploma'
);
