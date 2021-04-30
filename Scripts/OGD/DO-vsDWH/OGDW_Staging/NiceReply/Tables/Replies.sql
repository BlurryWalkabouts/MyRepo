CREATE TABLE [NiceReply].[Replies]
(
	[userName]    VARCHAR (256)  NULL,
	[created]     BIGINT         NULL,
	[score]       INT            NULL,
	[from_]       VARCHAR (256)  NULL,
	[ipAddr]      VARCHAR (20)   NULL,
	[ticket]      VARCHAR (512)  NULL,
	[comment]     NVARCHAR (MAX) NULL,
	[DateCreated] DATETIME       CONSTRAINT [DF_nicereply_DateCreated] DEFAULT SYSDATETIME() NOT NULL,
	[deleted]     BIT            DEFAULT 0 NULL
)