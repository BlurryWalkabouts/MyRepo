CREATE TABLE [history].[actiedoor] (
    [datwijzig]          DATETIME2 (7)  NULL,
    [ref_dynanaam]       NVARCHAR (255) NULL,
    [naam]               NVARCHAR (255) NULL,
    [unid]               VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]         INT            NOT NULL,
    [SourceDatabaseKey]  INT            NOT NULL,
    [ValidFrom]          DATETIME2 (0)  NOT NULL,
    [ValidTo]            DATETIME2 (0)  NOT NULL,
    [loginnaamtopdeskid] VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [vestigingid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [email]              NVARCHAR (255) NULL,
    [tasloginnaam]       NVARCHAR (255) NULL,
    [achternaam]         NVARCHAR (255) NULL,
    [tussenvoegsel]      NVARCHAR (255) NULL,
    [voornaam]           NVARCHAR (255) NULL
);



