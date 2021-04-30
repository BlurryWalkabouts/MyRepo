CREATE TABLE [TOPdesk].[probleemincidentlink] (
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [incidentid]        VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [probleemid]        VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);

