CREATE TABLE [TOPdesk].[wbaanvraagtype] (
    [naam]              NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_wbaanvraagtype_AuditDWKey_unid]
    ON [TOPdesk].[wbaanvraagtype]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

