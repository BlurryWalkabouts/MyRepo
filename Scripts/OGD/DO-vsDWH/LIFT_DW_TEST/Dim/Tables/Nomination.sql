CREATE TABLE [Dim].[Nomination]
(
	[NominationKey]     INT              NOT NULL,
	[unid]              UNIQUEIDENTIFIER NULL,
	[ProjectKey]        INT              NOT NULL,
	[CustomerKey]       INT              NOT NULL,
	[EmployeeKey]       INT              NOT NULL,
	[RequestNumber]     NVARCHAR (20)    NULL,
	[PlanningStartDate] DATE             NULL,
	[PlanningEndDate]   DATE             NULL,
	[WorkloadWeekly]    INT              NULL,
	[HourlyRate]        MONEY            NULL,
	[ChangeDate]        DATE             NULL,
	[Internal]          BIT              NULL,
	[NominationType]    CHAR (14)        NULL,
	[Status]            INT              NULL,
	CONSTRAINT [PK_Nomination] PRIMARY KEY (NominationKey),
--	CONSTRAINT [FK_Nomination_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES Dim.[Customer] ([CustomerKey]),
--	CONSTRAINT [FK_Nomination_EmployeeKey] FOREIGN KEY ([EmployeeKey]) REFERENCES Dim.[Employee] ([EmployeeKey]),
--	CONSTRAINT [FK_Nomination_ProjectKey] FOREIGN KEY ([ProjectKey]) REFERENCES Dim.[Project] ([ProjectKey])
)