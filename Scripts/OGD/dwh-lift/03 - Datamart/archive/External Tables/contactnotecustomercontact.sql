CREATE EXTERNAL TABLE [archive].[contactnotecustomercontact] (
    [unid]                uniqueidentifier  NOT NULL,
    [dataanmk]            datetime2(0)      NULL,
    [datwijzig]           datetime2(0)      NULL,
    [uidaanmk]            uniqueidentifier  NULL,
    [uidwijzig]           uniqueidentifier  NULL,
    [customerid]          uniqueidentifier  NULL,
    [customercontactid]   uniqueidentifier  NULL,
    [type]                nvarchar(60)      NULL,
    [categorie]           nvarchar(25)      NULL,
    [acquisition_goal]    nvarchar(30)      NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'contactnotecustomercontact'
);
