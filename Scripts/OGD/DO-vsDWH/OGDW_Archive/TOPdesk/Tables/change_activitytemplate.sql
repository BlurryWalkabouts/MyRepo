CREATE TABLE [TOPdesk].[change_activitytemplate] (
    [number]               NVARCHAR (255)                                     NULL,
    [operatorgroupid]      VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NULL,
    [duration_in_minutes]  BIGINT                                             NULL,
    [duration_in_workdays] BIGINT                                             NULL,
    [unid]                 VARCHAR (36)                                       COLLATE SQL_Latin1_General_CP1_CS_AS NOT NULL,
    [AuditDWKey]           INT                                                NOT NULL,
    [SourceDatabaseKey]    INT                                                NOT NULL,
    [ValidFrom]            DATETIME2 (0) GENERATED ALWAYS AS ROW START HIDDEN CONSTRAINT [DF_TOPdeskchange_activitytemplateSysStart] DEFAULT (CONVERT([datetime2](0),'0000-01-01 00:00:00')) NOT NULL,
    [ValidTo]              DATETIME2 (0) GENERATED ALWAYS AS ROW END HIDDEN   CONSTRAINT [DF_TOPdeskchange_activitytemplateSysEnd] DEFAULT (CONVERT([datetime2](0),'9999-12-31 23:59:59')) NOT NULL,
    CONSTRAINT [pk_TOPdeskchange_activitytemplate] PRIMARY KEY CLUSTERED ([unid] ASC, [AuditDWKey] ASC) WITH (DATA_COMPRESSION = PAGE),
    PERIOD FOR SYSTEM_TIME ([ValidFrom], [ValidTo])
)
WITH (SYSTEM_VERSIONING = ON (HISTORY_TABLE=[history].[change_activitytemplate], DATA_CONSISTENCY_CHECK=ON));

