CREATE TABLE [Dim].[NiceReply]
(
	[Reply_ID]          INT              NOT NULL,
	[SourceDatabaseKey] INT              NOT NULL,
	[CreationDate]      DATE             NULL,
	[CreationTime]      TIME (0)         NULL,
	[TicketLink]        VARCHAR (512)    NULL,
	[TicketType]        VARCHAR (20)     NULL,
	[TicketID]          UNIQUEIDENTIFIER NULL,
	[IPAddress]         VARCHAR (20)     NULL,
	[Score]             INT              NULL,
	[Comment]           NVARCHAR (MAX)   NULL,
	CONSTRAINT [PK_NiceReply] PRIMARY KEY CLUSTERED ([Reply_ID] ASC)
)