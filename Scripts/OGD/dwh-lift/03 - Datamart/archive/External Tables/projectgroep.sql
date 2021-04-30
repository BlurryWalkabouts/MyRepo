CREATE EXTERNAL TABLE [archive].[projectgroep] (
    [unid]             uniqueidentifier                                  NOT NULL,
    [klantid]          uniqueidentifier                                  NULL,
    [naam]             nvarchar(70)                                      NULL,
    [projectgroepnr]   nvarchar(11)                                      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'projectgroep'
);
