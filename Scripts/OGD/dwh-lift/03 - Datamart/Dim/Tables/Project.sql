CREATE TABLE [Dim].[Project]
(
	[ProjectKey]          INT              IDENTITY (40000000, 1) NOT FOR REPLICATION,
	[unid]                UNIQUEIDENTIFIER NULL,
	[ProjectNumber]       NVARCHAR (20)    NULL,
	[ProjectName]         NVARCHAR (70)    NOT NULL,
	[ChangeNumber]        AS CASE --Find ChangeNumber for different namingconventions
                             WHEN [ProjectName] LIKE 'W[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN LEFT([ProjectName], 12)
                             WHEN [ProjectName] LIKE 'W[A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'           THEN LEFT([ProjectName], 9)
                             WHEN [ProjectName] LIKE 'RFC[0-9][0-9]-[0-9][0-9]-[0-9][0-9][0-9]%'                 THEN LEFT([ProjectName], 12)
                             WHEN [ProjectName] LIKE 'W[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'                THEN LEFT([ProjectName], 9)
                             WHEN [ProjectName] LIKE 'W[0-9][0-9][0-9][0-9] [0-9][0-9][0-9]%'                    THEN LEFT([ProjectName], 9)
                             ELSE '-1'
                             END PERSISTED NOT NULL, --This column will probably used for joining other tables. Therefore an index will probably be added in the future. Therefore it needs to be persisted
	[ProblemNumber]      AS CASE --Find ProblemNumber for different namingconventions
                             WHEN [ProjectName] LIKE 'P[A-Z][A-Z][A-Z][0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%' THEN LEFT([ProjectName], 12)
                             WHEN [ProjectName] LIKE 'P[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]%'                THEN LEFT([ProjectName], 9)
                             ELSE '-1'
                             END PERSISTED NOT NULL, --This column will probably used for joining other tables. Therefore an index will probably be added in the future. Therefore it needs to be persisted
	[CustomerKey]         INT              NOT NULL,
	[OperatorKey]         INT              NOT NULL,
	[ProductGroup]        NVARCHAR (30)    NOT NULL,
	[Product]             NVARCHAR (30)    NOT NULL,
	[ProjectGroupNumber]  NVARCHAR (30)    NULL,
	[ProjectGroupName]    NVARCHAR (70)    NULL,
	[ProjectStatus]       INT              NULL,
	[ProjectStartDate]    DATE             NULL,
	[ProjectEndDate]      DATE             NULL,
	[ProjectCreationDate] DATE             NULL,
	[ProjectChangeDate]   DATE             NULL,
	[ProjectAcceptDate]   DATE             NULL,
	[ProjectArchiveDate]  DATE             NULL,
	[Office]              NVARCHAR (40)    NULL,
	[SalesTarget]         MONEY            NULL,
	[ProjectPrice]        MONEY            NULL, 
	[HasEnded]            BIT              NULL,
	[ProjectLedgerKey]    INT              NOT NULL,
	[ProjectLedgerNumber] NVARCHAR (10)    NOT NULL,
	CONSTRAINT [PK_Project] PRIMARY KEY CLUSTERED ([ProjectKey] ASC),
	CONSTRAINT [FK_Project_CustomerKey] FOREIGN KEY ([CustomerKey]) REFERENCES [Dim].[Customer] ([CustomerKey]),
	CONSTRAINT [FK_Project_OperatorKey] FOREIGN KEY ([OperatorKey]) REFERENCES [Dim].[Employee] ([EmployeeKey])
)