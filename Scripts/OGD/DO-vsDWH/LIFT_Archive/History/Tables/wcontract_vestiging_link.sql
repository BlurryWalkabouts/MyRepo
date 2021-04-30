CREATE TABLE [History].[wcontract_vestiging_link] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [vestigingid]    UNIQUEIDENTIFIER NULL,
    [wcontractid]    UNIQUEIDENTIFIER NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

