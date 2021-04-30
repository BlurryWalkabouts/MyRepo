CREATE TABLE [history].[incident__memogeschiedenis] (
    [parentid]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]         DATETIME2 (7) NULL,
    [unid]              VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]        INT           NOT NULL,
    [SourceDatabaseKey] INT           NOT NULL,
    [ValidFrom]         DATETIME2 (0) NOT NULL,
    [ValidTo]           DATETIME2 (0) NOT NULL
);

