CREATE TABLE [TOPdesk].[probleem_impact] (
    [naam]              NVARCHAR (255) NOT NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

