CREATE EXTERNAL TABLE [archive].[voordracht] (
    [unid]                         uniqueidentifier                                  NOT NULL,
    [datwijzig]                    datetime                                          NULL,
    [status]                       int                                               NULL,
    [projectid]                    uniqueidentifier                                  NULL,
    [aanvraagid]                   uniqueidentifier                                  NULL,
    [uurprijs]                     money                                             NULL,
    [intern]                       bit                                               NULL,
    [productid]                    uniqueidentifier                                  NULL,
    [grootboekid]                  uniqueidentifier                                  NULL,
    [werklast]                     int                                               NULL,
    [startdatum]                   datetime                                          NULL,
    [einddatum]                    datetime                                          NULL,
    [employeeid]                   uniqueidentifier                                  NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'voordracht'
);
