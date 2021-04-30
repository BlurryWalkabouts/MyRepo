CREATE TABLE [history].[locatie] (
    [ref_plaats1]       NVARCHAR (255) NULL,
    [ref_vestiging]     NVARCHAR (255) NULL,
    [vestigingid]       VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [datwijzig]         DATETIME2 (7)  NULL,
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NOT NULL,
    [ValidFrom]         DATETIME2 (0)  NOT NULL,
    [ValidTo]           DATETIME2 (0)  NOT NULL,
    [naam]              NVARCHAR (255) NULL
);



