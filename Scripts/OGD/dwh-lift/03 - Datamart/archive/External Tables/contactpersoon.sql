CREATE EXTERNAL TABLE [archive].[contactpersoon] (
    [unid]               uniqueidentifier                                  NOT NULL,
    [klantid]            uniqueidentifier                                  NULL,
    [status]             int                                               NULL,
    [anaam]              nvarchar(30)                                      NULL,
    [tvoegsel]           nvarchar(10)                                      NULL,
    [rnaam]              nvarchar(20)                                      NULL,
    [geslacht]           int                                               NULL,
    [afdeling]           nvarchar(60)                                      NULL,
    [functie]            nvarchar(50)                                      NULL,
    [verantwoordingid]   uniqueidentifier                                  NULL,
    [rol]                nvarchar(30)                                      NULL,
    [tel1]               nvarchar(25)                                      NULL,
    [tel2]               nvarchar(25)                                      NULL,
    [email]              nvarchar(70)                                      NULL,
    [linkedin]           nvarchar(120)                                     NULL,
    [exveld002]          nvarchar(250)                                     NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'contactpersoon'
);
