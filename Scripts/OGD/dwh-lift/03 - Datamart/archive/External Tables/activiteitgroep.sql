CREATE EXTERNAL TABLE [archive].[activiteitgroep] (
    [unid]         uniqueidentifier                                  NOT NULL,
    [status]       int                                               NULL,
    [naam]         nvarchar(30)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'activiteitgroep'
);
