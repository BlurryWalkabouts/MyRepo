CREATE TABLE [TOPdesk].[persoon] (
    [geslacht]          INT            CONSTRAINT [DF_persoon_geslacht] DEFAULT 0 NOT NULL,
    [mobiel]            NVARCHAR (255) NULL,
    [plaats]            NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [datwijzig]         DATETIME       NULL,
    [SourceDatabaseKey] INT            NULL
);




GO
CREATE CLUSTERED INDEX [IX_persoon_AuditDWKey_unid]
    ON [TOPdesk].[persoon]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NCIX_TopdeskPersoon]
    ON [TOPdesk].[persoon]([AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);


GO
CREATE NONCLUSTERED INDEX [NCIX_TopdeskIncident]
    ON [TOPdesk].[persoon]([AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

