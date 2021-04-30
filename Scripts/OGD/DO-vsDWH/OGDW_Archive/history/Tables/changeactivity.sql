CREATE TABLE [history].[changeactivity] (
    [approved]                     BIT            NULL,
    [approveddate]                 DATETIME2 (7)  NULL,
    [briefdescription]             NVARCHAR (255) NULL,
    [categoryid]                   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [changeid]                     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [currentplantimetaken]         BIGINT         NULL,
    [dataanmk]                     DATETIME2 (7)  NULL,
    [datwijzig]                    DATETIME2 (7)  NULL,
    [number]                       NVARCHAR (255) NULL,
    [operatorgroupid]              VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [operatorid]                   VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [originalplantimetaken]        BIGINT         NULL,
    [changephase]                  INT            NULL,
    [plannedfinaldate]             DATETIME2 (7)  NULL,
    [plannedstartdate]             DATETIME2 (7)  NULL,
    [rejected]                     BIT            NULL,
    [rejecteddate]                 DATETIME2 (7)  NULL,
    [resolved]                     BIT            NULL,
    [resolveddate]                 DATETIME2 (7)  NULL,
    [skipped]                      BIT            NULL,
    [skippeddate]                  DATETIME2 (7)  NULL,
    [started]                      BIT            NULL,
    [starteddate]                  DATETIME2 (7)  NULL,
    [status]                       INT            NULL,
    [subcategoryid]                VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [timetaken]                    BIGINT         NULL,
    [uidaanmk]                     VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [uidwijzig]                    VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [activitystatusid]             VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [maystart]                     BIT            NULL,
    [ref_change_brief_description] NVARCHAR (255) NULL,
    [activitytemplateid]           VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [unid]                         VARCHAR (36)   COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]                   INT            NOT NULL,
    [SourceDatabaseKey]            INT            NOT NULL,
    [ValidFrom]                    DATETIME2 (0)  NOT NULL,
    [ValidTo]                      DATETIME2 (0)  NOT NULL
);


GO
CREATE NONCLUSTERED INDEX [NCIX_HistoryChangeActivity_SDK]
    ON [history].[changeactivity]([SourceDatabaseKey] ASC)
    INCLUDE([unid], [AuditDWKey]);

