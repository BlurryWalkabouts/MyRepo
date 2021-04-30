CREATE TABLE [Staging].[activiteitgroep_voordracht_planning] (
    [unid]                         UNIQUEIDENTIFIER NULL,
    [activiteitgroep_voordrachtid] UNIQUEIDENTIFIER NULL,
    [startdatum]                   DATETIME         NULL,
	[einddatum]                    DATETIME         NULL,
    [aantal]                       INT              NULL,
    [AuditDWKey]                   INT              NULL
);