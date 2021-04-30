CREATE TABLE [Dim].[ActivityGroup]
(
	[ActivityGroupKey]      INT                        IDENTITY (15000000, 1) NOT FOR REPLICATION,
	[unid]                  UNIQUEIDENTIFIER           NULL,
	[ActivityGroupName]     NVARCHAR(30)               NULL,
	[ActivityGroupStatus]   INT                        NULL,
   CONSTRAINT PK_ActivityGroupKey PRIMARY KEY CLUSTERED (ActivityGroupKey)
)
