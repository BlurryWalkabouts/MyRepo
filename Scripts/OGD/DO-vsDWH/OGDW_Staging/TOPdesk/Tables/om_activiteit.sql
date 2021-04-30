CREATE TABLE [TOPdesk].[om_activiteit] (
    [unid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [afgemeld]          BIT            NOT NULL,
    [behandelaarid]     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [bestedetijd]       BIGINT         NOT NULL,
    [datumafgemeld]     DATETIME       NULL,
    [einddatumgepland]  DATETIME       NOT NULL,
    [naam]              NVARCHAR (255) NOT NULL,
    [overgeslagen]      BIT            NOT NULL,
    [reeksid]           VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [schemaid]          VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [startdatumgepland] DATETIME       NOT NULL,
    [status]            INT            NOT NULL,
    [nummer]            NVARCHAR (255) NOT NULL,
    [dataanmk]          DATETIME       NULL,
    [datwijzig]         DATETIME       NULL,
    [uidaanmk]          VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [operatorgroupid]   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

