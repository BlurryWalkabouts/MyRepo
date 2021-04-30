CREATE TABLE [Dim].[EmployeeContract]
(
	[EmployeeContractKey]  INT              IDENTITY (70000000, 1) NOT FOR REPLICATION,
	[unid]                 UNIQUEIDENTIFIER NULL,
	[EmployeeKey]          INT              NOT NULL,
	[ContractCreationDate] DATETIME         NULL,
	[ContractChangeDate]   DATETIME         NULL,
	[ContractStatus]       INT              NULL,
	[ContractType]         NVARCHAR (30)    NULL,
	[Percentage]           DECIMAL (5,2)    NULL,
	[ContractStartDate]    DATE             NULL,
	[ContractEndDate]      DATE             NULL,
	[SuggestedHourlyRate]  DECIMAL (19,4)   NULL,
	CONSTRAINT [PK_EmployeeContractKey] PRIMARY KEY CLUSTERED ([EmployeeContractKey]),
	CONSTRAINT [FK_EmployeeContract_EmployeeKey] FOREIGN KEY ([EmployeeKey]) REFERENCES [Dim].[Employee] ([EmployeeKey])
)