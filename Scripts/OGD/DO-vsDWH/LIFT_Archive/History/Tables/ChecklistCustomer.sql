CREATE TABLE [History].[ChecklistCustomer] (
    [unid]                     UNIQUEIDENTIFIER NOT NULL,
    [archief]                  INT              NULL,
    [rang]                     INT              NULL,
    [tekst]                    NVARCHAR (35)    NULL,
    [showForPotentialCustomer] INT              NULL,
    [showForCustomer]          INT              NULL,
    [afkorting]                NVARCHAR (10)    NULL,
    [AuditDWKey]           INT              NULL,
    [ValidFrom]                DATETIME2 (0)    NOT NULL,
    [ValidTo]                  DATETIME2 (0)    NOT NULL
);

