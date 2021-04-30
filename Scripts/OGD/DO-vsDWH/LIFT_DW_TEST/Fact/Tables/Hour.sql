CREATE TABLE [Fact].[Hour]
(
	[unid]              UNIQUEIDENTIFIER NULL,
	[ProjectKey]        INT              NOT NULL,
	[CustomerKey]       INT              NOT NULL,
	[EmployeeKey]       INT              NOT NULL,
	[HourTypeKey]       INT              NOT NULL,
	[ServiceKey]        INT              NOT NULL,
	[Hours]             DECIMAL (19, 6)  NULL,
	[Day]               DATE             NULL,
	[ChangeDate]        DATE             NULL,
	[Rate]              DECIMAL (19, 4)  NULL,
	[ProductNomination] NVARCHAR (30)    NULL,
--	CONSTRAINT [FK_Hour_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES Dim.[Customer] ([CustomerKey]),
--	CONSTRAINT [FK_Hour_Day] FOREIGN KEY ([Day]) REFERENCES Dim.[Date] ([Date]),
--	CONSTRAINT [FK_Hour_EmployeeKey] FOREIGN KEY ([EmployeeKey]) REFERENCES Dim.[Employee] ([EmployeeKey]),
--	CONSTRAINT [FK_Hour_ProjectKey] FOREIGN KEY ([ProjectKey]) REFERENCES Dim.[Project] ([ProjectKey]),
--	CONSTRAINT [FK_Hour_HourTypeKey] FOREIGN KEY ([HourTypeKey]) REFERENCES Dim.[HourType] ([HourTypeKey]),
--	CONSTRAINT [FK_Hour_ServiceKey] FOREIGN KEY ([ServiceKey]) REFERENCES Dim.[Service] ([ServiceKey])
)