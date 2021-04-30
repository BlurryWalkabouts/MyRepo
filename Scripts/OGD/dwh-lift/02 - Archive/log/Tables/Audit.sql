CREATE TABLE [log].[Audit] (
    [AuditDWKey]     INT       IDENTITY (1,1) NOT FOR REPLICATION,
    [DWDateCreated]  DATETIME2 CONSTRAINT [DF_DWDateCreatedUTC] DEFAULT SYSUTCDATETIME() NOT NULL,
    [DateImported]   DATETIME2 NULL,
    [BatchStartDate] DATETIME2 NULL,
    [BatchEndDate]   DATETIME2 NULL,
    [Deleted]        BIT       DEFAULT 0 NOT NULL,
    CONSTRAINT [PK_Audit] PRIMARY KEY CLUSTERED ([AuditDWKey] ASC)
);
