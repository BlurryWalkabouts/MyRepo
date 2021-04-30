CREATE EXTERNAL TABLE [archive].[activiteitgroep_voordracht] (
    [unid]              uniqueidentifier                                  NOT NULL,
    [datwijzig]         datetime                                          NULL,
    [status]            int                                               NULL,
    [projectid]         uniqueidentifier                                  NULL,
    [aanvraagid]        uniqueidentifier                                  NULL,
    [uurprijs]          money                                             NULL,
    [intern]            bit                                               NULL,
    [productid]         uniqueidentifier                                  NULL,
    [grootboekid]       uniqueidentifier                                  NULL,
    [activiteitgroepid] uniqueidentifier                                  NULL,
    [totale_werklast]   int                                               NULL,
    [startdatum_groep]  datetime                                          NULL,
    [einddatum_groep]   datetime                                          NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'activiteitgroep_voordracht'
);
