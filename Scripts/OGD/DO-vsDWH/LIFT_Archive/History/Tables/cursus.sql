CREATE TABLE [History].[cursus] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [werknemerid]    UNIQUEIDENTIFIER NULL,
    [naam]           NVARCHAR (35)    NULL,
    [leverancier]    NVARCHAR (20)    NULL,
    [cursusdatum]    DATETIME         NULL,
    [einddatum]      DATETIME         NULL,
    [dagen]          INT              NULL,
    [diploma]        BIT              NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

