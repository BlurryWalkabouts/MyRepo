CREATE EXTERNAL TABLE [archive].[vestiging] (
    [unid]         UNIQUEIDENTIFIER                                   NOT NULL,
    [tekst]        NVARCHAR (40)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'vestiging'
);
