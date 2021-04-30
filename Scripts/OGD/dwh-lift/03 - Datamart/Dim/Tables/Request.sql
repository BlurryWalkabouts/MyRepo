CREATE TABLE [Dim].[Request]
(
	[RequestKey]          INT              IDENTITY (130000000, 1) NOT FOR REPLICATION, 
	[unid]                UNIQUEIDENTIFIER NULL,
	[ProjectKey]          INT              NOT NULL,
	[RequestCreationDate] DATETIME         NULL,
	[RequestChangeDate]   DATETIME         NULL,
	[RequestArchiveDate]  DATETIME         NULL,
	[RequestAcceptDate]   DATETIME         NULL,
	[RequestNumber]       NVARCHAR (20)    NULL,
	[RequestStatus]       INT              NULL,
	[SalesChannel]        NVARCHAR (35)    NULL,
	[IsAdditionalRequest] BIT              NULL,
	[RequestSalesTarget]  DECIMAL (19, 4)  NULL,
	[SuccessChance]       INT              NULL, 
	[RequestValue]        DECIMAL (19, 4)  NULL,
	CONSTRAINT [PK_Request] PRIMARY KEY CLUSTERED ([RequestKey] ASC),
	CONSTRAINT [FK_Request_ProjectKey] FOREIGN KEY ([ProjectKey]) REFERENCES [Dim].[Project] ([ProjectKey])
)
