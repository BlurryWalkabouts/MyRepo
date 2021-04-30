CREATE EXTERNAL TABLE [archive].[gebruiker] (
    [unid]        uniqueidentifier                                  NOT NULL,
    [dataanmk]    datetime                                          NULL,
    [datwijzig]   datetime                                          NULL,
    [employeeid]  uniqueidentifier                                  NULL,
    [naam]        nvarchar(40)                                      NULL,
    [status]      int                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'gebruiker'
);
