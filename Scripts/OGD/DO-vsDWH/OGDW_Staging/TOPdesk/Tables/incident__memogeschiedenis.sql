CREATE TABLE [TOPdesk].[incident__memogeschiedenis] (
    [parentid]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]         DATETIME     NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);

