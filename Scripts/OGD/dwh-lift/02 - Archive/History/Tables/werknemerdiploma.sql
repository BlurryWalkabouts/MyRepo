CREATE TABLE [History].[werknemerdiploma] (
    [unid]            UNIQUEIDENTIFIER NOT NULL,
    [werknemerid]     UNIQUEIDENTIFIER NULL,
    [diplomaid]       UNIQUEIDENTIFIER NULL,
    [diploma]         NVARCHAR (25)    NULL,
    [expiration_date] DATETIME         NULL,
    [AuditDWKey]      INT              NULL,
    [ValidFrom]       DATETIME2 (0)    NOT NULL,
    [ValidTo]         DATETIME2 (0)    NOT NULL
);

