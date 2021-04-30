CREATE TABLE [TOPdesk].[dnocontract] (
    [naam]              NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [datwijzig]         DATETIME       NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_dnocontract_AuditDWKey_unid]
    ON [TOPdesk].[dnocontract]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

