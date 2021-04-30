CREATE TABLE [Staging].[cursus] (
    [unid]        UNIQUEIDENTIFIER NULL,
    [werknemerid] UNIQUEIDENTIFIER NULL,
    [naam]        NVARCHAR (35)    NULL,
    [leverancier] NVARCHAR (20)    NULL,
    [cursusdatum] DATETIME         NULL,
    [einddatum]   DATETIME         NULL,
    [dagen]       INT              NULL,
    [diploma]     BIT              NULL,
    [price]       MONEY            NULL,
    [AuditDWKey]  INT              NULL
);
