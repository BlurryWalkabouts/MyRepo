CREATE TABLE [TOPdesk].[change_template] (
    [briefdescription]  NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [datwijzig]         DATETIME       NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_change_template_AuditDWKey_unid]
    ON [TOPdesk].[change_template]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

