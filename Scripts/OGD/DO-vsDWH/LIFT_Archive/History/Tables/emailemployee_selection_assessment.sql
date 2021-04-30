CREATE TABLE [History].[emailemployee_selection_assessment] (
    [unid]                            UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]                        DATETIME         NULL,
    [datwijzig]                       DATETIME         NULL,
    [uidaanmk]                        UNIQUEIDENTIFIER NULL,
    [uidwijzig]                       UNIQUEIDENTIFIER NULL,
    [emailid]                         UNIQUEIDENTIFIER NULL,
    [verzenddatum]                    DATETIME         NULL,
    [employee_selection_assessmentid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]                  INT              NULL,
    [ValidFrom]                       DATETIME2 (0)    NOT NULL,
    [ValidTo]                         DATETIME2 (0)    NOT NULL
);

