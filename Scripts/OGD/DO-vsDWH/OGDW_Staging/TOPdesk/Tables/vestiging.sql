CREATE TABLE [TOPdesk].[vestiging] (
    [naam]              NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [datwijzig]         DATETIME       NULL,
    [SourceDatabaseKey] INT            NULL,
    [plaats1]           NVARCHAR (255) NULL
);




GO
CREATE CLUSTERED INDEX [IX_vestiging_AuditDWKey_unid]
    ON [TOPdesk].[vestiging]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

