CREATE TABLE [TOPdesk].[version] (
    [version]           INT            NOT NULL,
    [build]             NVARCHAR (255) NULL,
    [product]           NVARCHAR (255) NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NULL
);

