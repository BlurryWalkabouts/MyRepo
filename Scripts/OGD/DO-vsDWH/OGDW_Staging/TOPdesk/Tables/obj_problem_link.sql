CREATE TABLE [TOPdesk].[obj_problem_link] (
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [objectid]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [problemid]         VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);

