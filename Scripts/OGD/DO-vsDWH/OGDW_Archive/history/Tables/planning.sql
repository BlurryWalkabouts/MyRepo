CREATE TABLE [history].[planning] (
    [unid]              VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [startdatum]        DATETIME2 (7) NULL,
    [einddatum]         DATETIME2 (7) NULL,
    [aantalherhalingen] INT           NOT NULL,
    [dataanmk]          DATETIME2 (7) NULL,
    [datwijzig]         DATETIME2 (7) NULL,
    [uidaanmk]          VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36)  COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [ingeplandtotdatum] DATETIME2 (7) NULL,
    [eindtype]          INT           NOT NULL,
    [AuditDWKey]        INT           NOT NULL,
    [SourceDatabaseKey] INT           NULL,
    [ValidFrom]         DATETIME2 (0) NOT NULL,
    [ValidTo]           DATETIME2 (0) NOT NULL
);

