CREATE TABLE [History].[activiteitgroep_voordracht_uurlasten_link] (
    [unid]                         UNIQUEIDENTIFIER NOT NULL,
    [activiteitgroep_voordrachtid] UNIQUEIDENTIFIER NULL,
    [uurlastenid]                  UNIQUEIDENTIFIER NULL,
    [budget]                       MONEY            NULL,
    [budget_categoryid]            UNIQUEIDENTIFIER NULL,
    [AuditDWKey]               INT              NULL,
    [ValidFrom]                    DATETIME2 (0)    NOT NULL,
    [ValidTo]                      DATETIME2 (0)    NOT NULL
);

