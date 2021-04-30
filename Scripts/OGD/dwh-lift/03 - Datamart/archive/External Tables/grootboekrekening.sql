CREATE EXTERNAL TABLE [archive].[grootboekrekening] (
    [unid]         uniqueidentifier                                  NOT NULL,
    [tekst]        nvarchar(10)                                      NULL,
    [omschrijving] nvarchar(30)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'grootboekrekening'
);
