CREATE TABLE [log].[LiftAudit]
(
	[LiftAuditDWKey] INT      IDENTITY (1,1) NOT FOR REPLICATION,
	[DWDateCreated]  DATETIME CONSTRAINT [DF_DwdatecreatedUTC] DEFAULT GETUTCDATE() NULL,
	[DateImported]   DATETIME NULL,
	[BatchStartDate] DATETIME NULL,
	[BatchEndDate]   DATETIME NULL,
	[Deleted]        BIT      DEFAULT 0 NULL,
	CONSTRAINT [PK_LiftAudit] PRIMARY KEY CLUSTERED ([LiftAuditDWKey] ASC)
)