CREATE TABLE [History].[activiteitgroep_voordracht_planning] (
    [unid]                         UNIQUEIDENTIFIER NOT NULL,
    [activiteitgroep_voordrachtid] UNIQUEIDENTIFIER NULL,
    [startdatum]                   DATETIME         NULL,
	[einddatum]                    DATETIME         NULL,
    [aantal]                       INT              NULL,
    [AuditDWKey]                   INT              NULL,
    [ValidFrom]                    DATETIME2 (0)    NOT NULL,
    [ValidTo]                      DATETIME2 (0)    NOT NULL
);

