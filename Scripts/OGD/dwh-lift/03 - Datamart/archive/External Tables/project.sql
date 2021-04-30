CREATE EXTERNAL TABLE [archive].[project] (
    [unid]            uniqueidentifier   NOT NULL,
    [dataanmk]        datetime           NULL,
    [datwijzig]       datetime           NULL,
    [status]          int                NULL,
    [archiefdatum]    datetime           NULL,
    [projectgroepid]  uniqueidentifier   NULL,
    [projectnr]       nvarchar(20)       NULL,
    [vestiging]       nvarchar(40)       NULL,
    [projectnaam]     nvarchar(70)       NULL,
    [productgroepid]  uniqueidentifier   NULL,
    [productid]       uniqueidentifier   NULL,
    [behandeldid]     uniqueidentifier   NULL,
    [datacceptatie]   datetime           NULL,
    [startdatum]      datetime           NULL,
    [einddatum]       datetime           NULL,
    [beeindigd]       bit                NULL,
    [fprojectprijs]   money              NULL,
    [sales_channel]   nvarchar(35)       NULL,
    [sales_target]    money              NULL,
    [vestigingid]     uniqueidentifier   NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'project'
);
