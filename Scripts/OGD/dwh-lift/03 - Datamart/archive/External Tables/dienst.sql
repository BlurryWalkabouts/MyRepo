CREATE EXTERNAL TABLE [archive].[dienst] (
    [unid]           uniqueidentifier                                  NOT NULL,
    [budgethouderid] uniqueidentifier                                  NULL,
    [grootboekid]    uniqueidentifier                                  NULL,
    [naam]           nvarchar(30)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'dienst'
);
