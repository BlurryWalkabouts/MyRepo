CREATE TABLE [History].[land] (
    [unid]            UNIQUEIDENTIFIER NOT NULL,
    [archief]         INT              NULL,
    [rang]            INT              NULL,
    [landnaam]        NVARCHAR (50)    NULL,
    [exactcode]       NVARCHAR (10)    NULL,
    [afascode]        NVARCHAR (10)    NULL,
    [kingcode]        NVARCHAR (10)    NULL,
    [pclengte]        INT              NULL,
    [nummereerst]     BIT              NULL,
    [nummerverplicht] BIT              NULL,
    [voertaalid]      UNIQUEIDENTIFIER NULL,
    [adrescontrole]   BIT              NULL,
    [afkorting]       NVARCHAR (10)    NULL,
    [AuditDWKey]  INT              NULL,
    [ValidFrom]       DATETIME2 (0)    NOT NULL,
    [ValidTo]         DATETIME2 (0)    NOT NULL
);

