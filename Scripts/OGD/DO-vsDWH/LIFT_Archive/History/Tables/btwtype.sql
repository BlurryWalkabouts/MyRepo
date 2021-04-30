CREATE TABLE [History].[btwtype] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [archief]           INT              NULL,
    [rang]              INT              NULL,
    [tekst]             NVARCHAR (20)    NULL,
    [tarief]            MONEY            NULL,
    [accountviewcode]   NVARCHAR (2)     NULL,
    [afascode]          NVARCHAR (10)    NULL,
    [exactcode]         NVARCHAR (10)    NULL,
    [kinggbnr]          NVARCHAR (10)    NULL,
    [provitgrootboekid] UNIQUEIDENTIFIER NULL,
    [afkorting]         NVARCHAR (10)    NULL,
    [twinfieldcode]     NVARCHAR (10)    NULL,
    [twinfieldledger]   NVARCHAR (10)    NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);



