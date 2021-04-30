CREATE TABLE [TOPdesk].[change_act_templ_dependency] (
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [headid]            VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [tailid]            VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [templateid]        VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);


GO
CREATE CLUSTERED INDEX [IX_change_act_templ_dependency_AuditDWKey_unid]
    ON [TOPdesk].[change_act_templ_dependency]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

