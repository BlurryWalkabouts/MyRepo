CREATE TABLE [TOPdesk].[change_activitytemplate] (
    [number]               NVARCHAR (255) NOT NULL,
    [unid]                 VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]           INT            NOT NULL,
    [SourceDatabaseKey]    INT            NULL,
    [operatorgroupid]      VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [duration_in_minutes]  BIGINT         NULL,
    [duration_in_workdays] BIGINT         NULL
);

