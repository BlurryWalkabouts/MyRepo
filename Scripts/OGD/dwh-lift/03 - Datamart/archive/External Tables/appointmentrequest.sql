CREATE EXTERNAL TABLE [archive].[appointmentrequest] (
    [unid]               uniqueidentifier                                  NOT NULL,
    [dataanmk]           datetime                                          NULL,
    [status]             int                                               NULL,
    [behandelaarid]      uniqueidentifier                                  NULL,
    [resultaat]          nvarchar(25)                                       NULL,
    [wfcategorie]        nvarchar(25)                                       NULL,
    [acquisition_goal]   nvarchar(30)                                       NULL,
    [afspraaktijd]       datetime                                          NULL,
    [onderwerp]          nvarchar(80)                                      NULL,
    [requestid]          uniqueidentifier                                  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'appointmentrequest'
);
