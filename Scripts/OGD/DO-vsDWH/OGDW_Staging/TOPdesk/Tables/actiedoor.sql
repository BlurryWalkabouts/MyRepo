CREATE TABLE [TOPdesk].[actiedoor] (
    [loginnaamtopdeskid] VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]               VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [vestigingid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]               NVARCHAR (255) NULL,
    [email]              NVARCHAR (255) NULL,
    [datwijzig]          DATETIME       NULL,
    [tasloginnaam]       NVARCHAR (255) NULL,
    [ref_dynanaam]       NVARCHAR (255) NULL,
    [AuditDWKey]         INT            NOT NULL,
    [SourceDatabaseKey]  INT            NULL,
    [achternaam]         NVARCHAR (255) NULL,
    [tussenvoegsel]      NVARCHAR (255) NULL,
    [voornaam]           NVARCHAR (255) NULL
);






GO


