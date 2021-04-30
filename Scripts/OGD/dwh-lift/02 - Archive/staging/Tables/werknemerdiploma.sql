CREATE TABLE [Staging].[werknemerdiploma] (
    [unid]            UNIQUEIDENTIFIER NULL,
    [werknemerid]     UNIQUEIDENTIFIER NULL,
    [diplomaid]       UNIQUEIDENTIFIER NULL,
    [diploma]         NVARCHAR (25)    NULL,
    [expiration_date] DATETIME         NULL,
    [AuditDWKey]      INT              NULL
);
