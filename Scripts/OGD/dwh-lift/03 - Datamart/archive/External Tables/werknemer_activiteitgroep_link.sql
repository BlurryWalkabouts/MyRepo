CREATE EXTERNAL TABLE [archive].[werknemer_activiteitgroep_link] (
    [unid]               uniqueidentifier NOT NULL,
    [werknemerid]        uniqueidentifier NULL,
    [activiteitgroepid]  uniqueidentifier NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'werknemer_activiteitgroep_link'
);
