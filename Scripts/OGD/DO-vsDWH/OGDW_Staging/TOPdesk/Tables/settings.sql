CREATE TABLE [TOPdesk].[settings] (
    [id]                VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [name]              NVARCHAR (255) NULL,
    [type]              INT            NULL,
    [characters]        NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

