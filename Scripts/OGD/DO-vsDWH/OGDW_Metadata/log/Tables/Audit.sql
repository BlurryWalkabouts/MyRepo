CREATE TABLE [log].[Audit]
(
	[AuditDWKey]           INT              IDENTITY (1,1) NOT FOR REPLICATION,
	[BatchDWKey]           INT              NULL,
	[SourceDatabaseKey]    INT              NOT NULL,
	[SourceName]           VARCHAR (255)    NOT NULL,
	[SourceType]           VARCHAR (50)     NOT NULL,
	[TargetName]           VARCHAR (100)    NOT NULL,
	[ServerExecutionID]    BIGINT           NULL,
	[ExecutionID]          UNIQUEIDENTIFIER NULL,
	[PackageGUID]          UNIQUEIDENTIFIER NULL,
	[PackageVersionGUID]   UNIQUEIDENTIFIER NULL,
	[Status]               INT              CONSTRAINT [DF__Audit__Status__2BFE89A6] DEFAULT ((0)) NOT NULL,
	[DWDateCreated]        DATETIME         CONSTRAINT [DF_Audit_DWDateCreated] DEFAULT GETDATE() NULL,
	[StagingSuccessful]    BIT              CONSTRAINT [DF__Audit__StagingSu__26DAAD2D] DEFAULT ((0)) NOT NULL,
	[StagingEndTime]       DATETIME         NULL,
	[StagingRowsProcessed] INT              CONSTRAINT [DF__Audit__RowsProce__2CF2ADDF] DEFAULT ((0)) NULL,
	[deleted]              BIT              CONSTRAINT [DF__Audit__deleted__1798699D] DEFAULT ((0)) NOT NULL,
	[AMDateImported]       DATETIME         NULL,
	CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED ([AuditDWKey] ASC)
)
GO

CREATE NONCLUSTERED INDEX [NCIX_LogAuditAuditDWKey]
	ON [log].[Audit] ([AuditDWKey] ASC)
GO