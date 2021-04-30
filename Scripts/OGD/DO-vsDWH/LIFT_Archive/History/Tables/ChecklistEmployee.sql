CREATE TABLE [History].[ChecklistEmployee] (
    [unid]                     UNIQUEIDENTIFIER NOT NULL,
    [archief]                  INT              NULL,
    [rang]                     INT              NULL,
    [tekst]                    NVARCHAR (35)    NULL,
    [showForCandidate]         INT              NULL,
    [showForPotentialEmployee] INT              NULL,
    [showForEmployee]          INT              NULL,
    [showForContractor]        INT              NULL,
    [afkorting]                NVARCHAR (10)    NULL,
    [AuditDWKey]           INT              NULL,
    [ValidFrom]                DATETIME2 (0)    NOT NULL,
    [ValidTo]                  DATETIME2 (0)    NOT NULL
);

