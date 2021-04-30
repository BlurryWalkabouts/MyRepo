CREATE TABLE [TOPdesk].[om_reeks] (
    [unid]                     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]                     NVARCHAR (255) NOT NULL,
    [schemaid]                 VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [planningid]               VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [status]                   INT            NOT NULL,
    [standaardbehandelaarid]   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [nummer]                   NVARCHAR (255) NOT NULL,
    [dataanmk]                 DATETIME       NULL,
    [datwijzig]                DATETIME       NULL,
    [uidaanmk]                 VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]                VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [standaardoperatorgroupid] VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]               INT            NOT NULL,
    [SourceDatabaseKey]        INT            NULL
);

