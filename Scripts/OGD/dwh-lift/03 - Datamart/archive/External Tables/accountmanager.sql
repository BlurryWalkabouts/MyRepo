CREATE EXTERNAL TABLE [archive].[accountmanager] (
    [unid]        uniqueidentifier                                  NOT NULL,
    [archief]     int                                               NULL,
    [gebruikerid] uniqueidentifier                                  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'accountmanager'
);
