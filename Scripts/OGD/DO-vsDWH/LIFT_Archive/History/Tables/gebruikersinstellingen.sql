CREATE TABLE [History].[gebruikersinstellingen] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [instellingnaam] NVARCHAR (24)    NULL,
    [instelling]     NVARCHAR (MAX)   NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

