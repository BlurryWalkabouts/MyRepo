CREATE TABLE [TOPdesk].[dnolink] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [ref_naam]          NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_dnolink_AuditDWKey_unid]
    ON [TOPdesk].[dnolink]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

