CREATE EXTERNAL TABLE [archive].[betalingsconditie] (
    [unid]           uniqueidentifier  NOT NULL,
    [vervaltermijn]  int               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'betalingsconditie'
);
