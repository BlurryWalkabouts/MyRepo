CREATE TABLE [TOPdesk].[afdeling] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]              NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_afdeling_AuditDWKey_unid]
    ON [TOPdesk].[afdeling]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

