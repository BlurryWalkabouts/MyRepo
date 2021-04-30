CREATE TABLE [TOPdesk].[om_schema] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]              NVARCHAR (255) NOT NULL,
    [status]            INT            NOT NULL,
    [dataanmk]          DATETIME       NULL,
    [datwijzig]         DATETIME       NULL,
    [uidaanmk]          VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

