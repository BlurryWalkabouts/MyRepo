CREATE TABLE [TOPdesk].[afhandelingstatus] (
    [naam]              NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);


GO
CREATE CLUSTERED INDEX [IX_afhandelingstatus_AuditDWKey_unid]
    ON [TOPdesk].[afhandelingstatus]([SourceDatabaseKey] ASC, [AuditDWKey] ASC, [unid] ASC) WITH (FILLFACTOR = 90);

