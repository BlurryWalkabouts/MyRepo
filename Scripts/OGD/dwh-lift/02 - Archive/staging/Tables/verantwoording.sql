CREATE TABLE [Staging].[verantwoording] (
    [unid]       UNIQUEIDENTIFIER NULL,
    [archief]    INT              NULL,
    [rang]       INT              NULL,
    [tekst]      NVARCHAR (20)    NULL,
    [type]       INT              NULL,
    [afkorting]  NVARCHAR (10)    NULL,
    [AuditDWKey] INT              NULL
);
