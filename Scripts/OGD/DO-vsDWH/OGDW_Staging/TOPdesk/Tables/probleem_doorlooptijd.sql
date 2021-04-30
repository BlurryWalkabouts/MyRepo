CREATE TABLE [TOPdesk].[probleem_doorlooptijd] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]              NVARCHAR (255) NOT NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

