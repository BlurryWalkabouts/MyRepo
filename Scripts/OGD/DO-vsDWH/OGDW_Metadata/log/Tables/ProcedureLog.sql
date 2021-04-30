CREATE TABLE [log].[ProcedureLog]
(
	[LogID]          INT            IDENTITY (1,1) NOT FOR REPLICATION,
	[DatabaseID]     INT            NULL,
	[ObjectID]       INT            NULL,
	[ProcedureName]  NVARCHAR (400) NULL,
	[LoginName]      NVARCHAR (50)  NULL,
	[StartDate]      DATETIME       NULL,
	[EndDate]        DATETIME       NULL,
	[RunningTime]    INT            NULL,
	[Success]        BIT            NULL,
	[RowsCount]      INT            NULL,
	[ErrorNumber]    INT            NULL,
	[ErrorMessage]   NVARCHAR (MAX) NULL,
	[AdditionalInfo] NVARCHAR (MAX) NULL,
	CONSTRAINT [PK_ProcedureLog] PRIMARY KEY CLUSTERED ([LogID] ASC)
)