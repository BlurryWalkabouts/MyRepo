CREATE TABLE [TOPdesk].[gebruiker] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]              NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [datwijzig]         DATETIME       NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_gebruiker_AuditDWKey_unid]
    ON [TOPdesk].[gebruiker]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

