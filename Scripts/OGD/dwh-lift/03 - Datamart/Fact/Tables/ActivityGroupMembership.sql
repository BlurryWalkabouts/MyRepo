CREATE TABLE [Fact].[ActivityGroupMembership]
(
	[ActivityGroupKey]               INT                        NOT NULL DEFAULT -1,
	[EmployeeKey]                    INT                        NOT NULL DEFAULT -1,
	[unid]                           UNIQUEIDENTIFIER           NULL,	
	CONSTRAINT [FK_ActivityGroupMembership_ActivityGroup]       FOREIGN KEY ([ActivityGroupKey]) REFERENCES [Dim].[ActivityGroup] ([ActivityGroupKey]),
	CONSTRAINT [FK_ActivityGroupMembership_Employee]            FOREIGN KEY ([EmployeeKey])      REFERENCES [Dim].[Employee] ([EmployeeKey])
)
