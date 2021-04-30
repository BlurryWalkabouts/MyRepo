CREATE TABLE [Staging].[regio] (
    [unid]       UNIQUEIDENTIFIER NULL,
    [afkorting]  NVARCHAR (10)    NULL,
    [archief]    INT              NULL,
    [rang]       INT              NULL,
    [tekst]      NVARCHAR (100)   NULL,
    [AuditDWKey] INT              NULL
);
