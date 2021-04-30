CREATE EXTERNAL TABLE [archive].[uurtype] (
    [unid]                 uniqueidentifier                                  NOT NULL,
    [projectid]            uniqueidentifier                                  NULL,
    [procent]              money                                             NULL,
    [tariefnaam]           nvarchar(30)                                      NULL,
    [declarabel]           bit                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'uurtype'
);
