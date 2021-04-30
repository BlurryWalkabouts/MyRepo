CREATE EXTERNAL TABLE [archive].[klant] (
    [unid]                                     uniqueidentifier                                  NOT NULL,
    [status]                                   int                                               NULL,
    [bedrijf]                                  nvarchar(60)                                      NULL,
    [grootte]                                  nvarchar(25)                                      NULL,
    [debnr]                                    nvarchar(6)                                       NULL,
    [behandelaarid]                            uniqueidentifier                                  NULL,
    [kvknr]                                    nvarchar(30)                                      NULL,
    [btwnr]                                    nvarchar(30)                                      NULL,
    [regio]                                    nvarchar(100)                                     NULL,
    [straat1]                                  nvarchar(50)                                      NULL,
    [nummer1]                                  nvarchar(20)                                      NULL,
    [postcode1]                                nvarchar(15)                                      NULL,
    [plaats1]                                  nvarchar(30)                                      NULL,
    [land1]                                    nvarchar(50)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'klant'
);
