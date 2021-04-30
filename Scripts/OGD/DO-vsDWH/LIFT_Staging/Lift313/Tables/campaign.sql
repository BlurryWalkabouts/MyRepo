CREATE TABLE [Lift313].[campaign] (
    [unid]                    UNIQUEIDENTIFIER NULL,
    [archief]                 INT              NULL,
    [rang]                    INT              NULL,
    [tekst]                   NVARCHAR (30)    NULL,
    [afkorting]               NVARCHAR (10)    NULL,
    [klant1_visible]          BIT              NULL,
    [klant2_visible]          BIT              NULL,
    [contactpersoon1_visible] BIT              NULL,
    [werknemer1_visible]      BIT              NULL,
    [werknemer2_visible]      BIT              NULL,
    [werknemer3_visible]      BIT              NULL,
    [werknemer4_visible]      BIT              NULL,
    [AuditDWKey]          INT              NULL
);

