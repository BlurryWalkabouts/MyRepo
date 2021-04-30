CREATE TABLE [History].[assignment_hour] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [old_amount]         MONEY            NULL,
    [datum]              DATETIME         NULL,
    [verwerkt_factuur]   BIT              NULL,
    [factuurid]          UNIQUEIDENTIFIER NULL,
    [seen_by_invoice_id] UNIQUEIDENTIFIER NULL,
    [hourtypeid]         UNIQUEIDENTIFIER NULL,
    [assignmentid]       UNIQUEIDENTIFIER NULL,
    [seconds]            BIGINT           NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);



