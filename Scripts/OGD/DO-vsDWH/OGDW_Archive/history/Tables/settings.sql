CREATE TABLE [history].[settings] (
    [id]                VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [name]              NVARCHAR (255) NULL,
    [type]              INT            NULL,
    [characters]        NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NOT NULL,
    [ValidFrom]         DATETIME2 (0)  NOT NULL,
    [ValidTo]           DATETIME2 (0)  NOT NULL
);

