CREATE EXTERNAL TABLE [archive].[activiteitgroep_voordracht_planning] (
    [activiteitgroep_voordrachtid]  uniqueidentifier  NULL,
    [startdatum]                    datetime          NULL,
    [einddatum]                     datetime          NULL,
    [aantal]                        int               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'activiteitgroep_voordracht_planning'
);
