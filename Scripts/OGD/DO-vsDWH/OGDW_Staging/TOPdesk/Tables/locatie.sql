CREATE TABLE [TOPdesk].[locatie] (
    [ref_plaats1]       NVARCHAR (255) NOT NULL,
    [ref_vestiging]     NVARCHAR (255) NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [vestigingid]       VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]         DATETIME       NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL,
    [naam]              NVARCHAR (255) NULL
);



