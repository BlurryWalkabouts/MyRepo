CREATE TABLE [TOPdesk].[actiedoor] (
    [datwijzig]          DATETIME2 (7)                                      NULL,
    [ref_dynanaam]       NVARCHAR (255)                                     NULL,
    [naam]               NVARCHAR (255)                                     NULL,
    [unid]               VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]         INT                                                NOT NULL,
    [SourceDatabaseKey]  INT                                                NOT NULL,
    [ValidFrom]          DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskactiedoorSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]            DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskactiedoorSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    [loginnaamtopdeskid] VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [vestigingid]        VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [email]              NVARCHAR (255)                                     NULL,
    [tasloginnaam]       NVARCHAR (255)                                     NULL,
    [achternaam]         NVARCHAR (255)                                     NULL,
    [tussenvoegsel]      NVARCHAR (255)                                     NULL,
    [voornaam]           NVARCHAR (255)                                     NULL,
    CONSTRAINT [pk_TOPdeskactiedoor] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[actiedoor], DATA_CONSISTENCY_CHECK=ON));



