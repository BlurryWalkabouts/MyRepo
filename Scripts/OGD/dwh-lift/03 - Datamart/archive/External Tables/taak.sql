CREATE EXTERNAL TABLE [archive].[taak] (
    [unid]                     uniqueidentifier                                  NOT NULL,
    [status]                   int                                               NULL,
    [taaknr]                   nvarchar(8)                                       NULL,
    [taaknaam]                 nvarchar(30)                                      NULL,
    [iedereen]                 bit                                               NULL,
    [einddatum]                datetime                                          NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'taak'
);
