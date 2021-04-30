CREATE TABLE [History].[doc_trefwoorden] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [documentid]     UNIQUEIDENTIFIER NULL,
    [trefwoord]      NVARCHAR (60)    NULL,
    [trefwoordid]    UNIQUEIDENTIFIER NULL,
    [standaard]      BIT              NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

