CREATE EXTERNAL TABLE [archive].[budgethouder] (
    [unid]             uniqueidentifier                                  NOT NULL,
    [tekst]            nvarchar(30)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'budgethouder'
);
