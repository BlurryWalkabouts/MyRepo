CREATE TABLE [TOPdesk].[changeactivity__dependency] (
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [headid]            VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [tailid]            VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);


GO
CREATE CLUSTERED INDEX [IX_changeactivity__dependency_AuditDWKey_unid]
    ON [TOPdesk].[changeactivity__dependency]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

