CREATE TABLE [monitoring].[ReportExecutions]
(
	[ReportExecutionDWKey] INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[LogEntryID]           BIGINT         NOT NULL,
	[ItemPath]             NVARCHAR (MAX) NULL,
	[UserName]             NVARCHAR (260) NULL,
	[ReportName]           NVARCHAR (425) NULL,
	[RequestType]          VARCHAR (13)   NOT NULL,
	[ReportAction]         VARCHAR (21)   NOT NULL,
	[TimeStart]            DATETIME       NOT NULL,
	[TimeEnd]              DATETIME       NOT NULL,
	[TimeDataRetrieval]    INT            NOT NULL,
	[TimeProcessing]       INT            NOT NULL,
	[TimeRendering]        INT            NOT NULL,
	[Source]               VARCHAR (8)    NOT NULL,
	[Status]               NVARCHAR (40)  NOT NULL,
	[ByteCount]            BIGINT         NOT NULL,
	[RowsCount]             BIGINT         NOT NULL,
	CONSTRAINT [PK_ReportExecutions] PRIMARY KEY CLUSTERED ([ReportExecutionDWKey] ASC)
)