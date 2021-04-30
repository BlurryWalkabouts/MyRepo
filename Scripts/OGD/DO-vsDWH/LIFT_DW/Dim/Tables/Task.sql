CREATE TABLE [Dim].[Task]
(
	[TaskKey]     INT              IDENTITY (120000000, 1) NOT FOR REPLICATION,
	[unid]        UNIQUEIDENTIFIER NULL,
	[TaskNumber]  NVARCHAR (20)    NULL,
	[TaskName]    NVARCHAR (70)    NULL,
	[TaskStatus]  INT              NULL,
	[IsPublic]    BIT              NULL,
	[TaskEndDate] DATE             NULL,
	CONSTRAINT [PK_Task] PRIMARY KEY CLUSTERED ([TaskKey] ASC)
)