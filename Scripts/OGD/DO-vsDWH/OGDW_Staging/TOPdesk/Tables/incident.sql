CREATE TABLE [TOPdesk].[incident] (
    [aanmelderafdelingid]    VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [aanmelderlokatieid]     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [aanmeldertelefoon]      NVARCHAR (255) CONSTRAINT [DF_incident_aanmeldertelefoon] DEFAULT (N'[Onbekend]') NOT NULL,
    [aanmeldervestigingid]   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [afgemeld]               BIT            NOT NULL,
    [afhandelingstatusid]    VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [configuratieid]         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [configuratieobjectid]   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [dnoid]                  VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [doorlooptijdid]         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [gereed]                 BIT            NOT NULL,
    [persoonid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [ref_dnocontractid]      VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [ref_domein]             NVARCHAR (255) NOT NULL,
    [ref_impact]             NVARCHAR (255) NOT NULL,
    [ref_soortmelding]       NVARCHAR (255) NOT NULL,
    [ref_specificatie]       NVARCHAR (255) NOT NULL,
    [soortbinnenkomstid]     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [status]                 INT            NOT NULL,
    [uidaanmk]               VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]                   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [dataanmk]               DATETIME       NULL,
    [datumaangemeld]         DATETIME       NULL,
    [datumafgemeld]          DATETIME       NULL,
    [datumafspraak]          DATETIME       NULL,
    [datumgereed]            DATETIME       NULL,
    [datwijzig]              DATETIME       NULL,
    [lijn1tijdbesteed]       BIGINT         NOT NULL,
    [tijdbesteed]            BIGINT         NOT NULL,
    [totaletijd]             BIGINT         NOT NULL,
    [minutendoorlooptijd]    BIGINT         NOT NULL,
    [dnostatus]              INT            NOT NULL,
    [korteomschrijving]      NVARCHAR (255) NOT NULL,
    [datumafspraaksla]       DATETIME       NULL,
    [oplossingid]            VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [naam]                   NVARCHAR (255) NOT NULL,
    [ismajorincident]        BIT            NOT NULL,
    [majorincidentid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [vrijetekst1]            NVARCHAR (255) NULL,
    [servicewindowid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [externnummer]           NVARCHAR (255) NOT NULL,
    [aanmelderemail]         NVARCHAR (255) CONSTRAINT [DF_incident_aanmelderemail] DEFAULT (N'[Onbekend]') NOT NULL,
    [onhold]                 BIT            NOT NULL,
    [onholdduration]         BIGINT         NOT NULL,
    [onholddatum]            DATETIME       NULL,
    [priorityid]             VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [supplierid]             VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [aanmeldernaam]          NVARCHAR (255) CONSTRAINT [DF_incident_aanmeldernaam] DEFAULT (N'[Onbekend]') NOT NULL,
    [ref_operatordynanaam]   NVARCHAR (255) NOT NULL,
    [ref_operatorgroup]      NVARCHAR (255) NOT NULL,
    [adjusteddurationonhold] BIGINT         NOT NULL,
    [vrijememo1]             NVARCHAR (MAX) NULL,
    [vrijememo2]             NVARCHAR (MAX) NULL,
    [vrijememo3]             NVARCHAR (MAX) NULL,
    [AuditDWKey]             INT            NOT NULL,
    [SourceDatabaseKey]      INT            NULL,
    [impactid]               VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [incident_domeinid]      VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [incident_specid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [operatorgroupid]        VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [operatorid]             VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [soortmeldingid]         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL
);






GO



GO


