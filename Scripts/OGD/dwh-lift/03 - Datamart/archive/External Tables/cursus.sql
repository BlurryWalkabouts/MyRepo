CREATE EXTERNAL TABLE [archive].[cursus] (
    [unid]        uniqueidentifier                                  NOT NULL,
    [werknemerid] uniqueidentifier                                  NULL,
    [naam]        nvarchar(35)                                      NULL,
    [leverancier] nvarchar(20)                                      NULL,
    [cursusdatum] datetime                                          NULL,
    [einddatum]   datetime                                          NULL,
    [dagen]       int                                               NULL,
    [diploma]     bit                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'cursus'
);
