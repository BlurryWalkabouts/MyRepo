CREATE EXTERNAL TABLE [archive].[taakvoordracht] (
    [unid]        uniqueidentifier                                  NOT NULL,
    [datwijzig]   datetime                                          NULL,
    [status]      int                                               NULL,
    [taakid]      uniqueidentifier                                  NULL,
    [startdatum]  datetime                                          NULL,
    [einddatum]   datetime                                          NULL,
    [werklast]    int                                               NULL,
    [employeeid]  uniqueidentifier                                  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'taakvoordracht'
);
