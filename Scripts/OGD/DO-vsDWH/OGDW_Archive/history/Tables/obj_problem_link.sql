CREATE TABLE [history].[obj_problem_link] (
    [objectid]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [problemid]         VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]              VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]        INT           NOT NULL,
    [SourceDatabaseKey] INT           NOT NULL,
    [ValidFrom]         DATETIME2 (0) NOT NULL,
    [ValidTo]           DATETIME2 (0) NOT NULL
);

