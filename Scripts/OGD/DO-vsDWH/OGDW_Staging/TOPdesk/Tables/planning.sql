CREATE TABLE [TOPdesk].[planning] (
    [unid]              VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [startdatum]        DATETIME     NULL,
    [einddatum]         DATETIME     NULL,
    [aantalherhalingen] INT          NOT NULL,
    [dataanmk]          DATETIME     NULL,
    [datwijzig]         DATETIME     NULL,
    [uidaanmk]          VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]         VARCHAR (36) COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [ingeplandtotdatum] DATETIME     NULL,
    [eindtype]          INT          NOT NULL,
    [AuditDWKey]        INT          NOT NULL,
    [SourceDatabaseKey] INT          NULL
);

