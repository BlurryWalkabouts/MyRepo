CREATE TABLE [Dim].[Course]
(
	[CourseKey]       INT              IDENTITY (80000000, 1) NOT FOR REPLICATION,
	[unid]            UNIQUEIDENTIFIER NULL,
	[EmployeeKey]     INT              NOT NULL,
	[Provider]        NVARCHAR (20)    NULL,
	[CourseName]      NVARCHAR (35)    NULL,
	[CourseDate]      DATE             NULL,
	[CourseEndDate]   DATE             NULL,
	[CourseDuration]  INT              NULL,
	[DiplomaObtained] BIT              NULL,
	CONSTRAINT [PK_Course] PRIMARY KEY CLUSTERED ([CourseKey]),
	CONSTRAINT [FK_Course_EmployeeKey] FOREIGN KEY ([EmployeeKey]) REFERENCES [Dim].[Employee] ([EmployeeKey])
)