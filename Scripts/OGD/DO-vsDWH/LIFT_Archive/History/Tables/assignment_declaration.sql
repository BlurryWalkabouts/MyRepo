CREATE TABLE [History].[assignment_declaration] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [aantal]             MONEY            NULL,
    [datum]              DATETIME         NULL,
    [verwerkt_factuur]   BIT              NULL,
    [factuurid]          UNIQUEIDENTIFIER NULL,
    [seen_by_invoice_id] UNIQUEIDENTIFIER NULL,
    [aantekeningen]      NVARCHAR (MAX)   NULL,
    [declarationid]      UNIQUEIDENTIFIER NULL,
    [assignmentid]       UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

