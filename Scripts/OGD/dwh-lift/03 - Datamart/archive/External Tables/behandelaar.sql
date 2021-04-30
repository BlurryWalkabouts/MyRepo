CREATE EXTERNAL TABLE [archive].[behandelaar] (
    [unid]        uniqueidentifier                                  NOT NULL,
    [gebruikerid] uniqueidentifier                                  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'behandelaar'
);
