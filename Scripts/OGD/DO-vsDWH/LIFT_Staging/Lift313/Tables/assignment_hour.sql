CREATE TABLE [Lift313].[assignment_hour] (
    [seconds]            BIGINT           NULL,
    [old_amount]         MONEY            NULL,
    [unid]               UNIQUEIDENTIFIER NULL,
    [dataanmk]           DATETIME         NULL,
    [datwijzig]          DATETIME         NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [datum]              DATETIME         NULL,
    [verwerkt_factuur]   BIT              NULL,
    [factuurid]          UNIQUEIDENTIFIER NULL,
    [seen_by_invoice_id] UNIQUEIDENTIFIER NULL,
    [hourtypeid]         UNIQUEIDENTIFIER NULL,
    [assignmentid]       UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

