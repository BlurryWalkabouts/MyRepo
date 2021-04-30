CREATE TABLE [Fact].[EmployeeDiploma]
(
	[unid]           UNIQUEIDENTIFIER NULL,
	[EmployeeKey]    INT              NOT NULL,
	[DiplomaKey]     INT              NOT NULL,
	[ExpirationDate] DATE             NULL,
	CONSTRAINT [FK_EmployeeDiploma_EmployeeKey] FOREIGN KEY ([EmployeeKey]) REFERENCES [Dim].[Employee] ([EmployeeKey]),
	CONSTRAINT [FK_EmployeeDiploma_DiplomaKey] FOREIGN KEY ([DiplomaKey]) REFERENCES [Dim].[Diploma] ([DiplomaKey]),
)