CREATE TABLE [History].[campaign_contactpersoon_link] (
    [unid]             UNIQUEIDENTIFIER NOT NULL,
    [dataanmk]         DATETIME         NULL,
    [datwijzig]        DATETIME         NULL,
    [uidaanmk]         UNIQUEIDENTIFIER NULL,
    [uidwijzig]        UNIQUEIDENTIFIER NULL,
    [campaignid]       UNIQUEIDENTIFIER NULL,
    [vendorid]         UNIQUEIDENTIFIER NULL,
    [progressid]       UNIQUEIDENTIFIER NULL,
    [contactpersoonid] UNIQUEIDENTIFIER NULL,
    [AuditDWKey]   INT              NULL,
    [ValidFrom]        DATETIME2 (0)    NOT NULL,
    [ValidTo]          DATETIME2 (0)    NOT NULL
);

