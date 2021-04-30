CREATE TABLE [history].[version] (
    [build]             NVARCHAR (255) NULL,
    [product]           NVARCHAR (255) NULL,
    [version]           VARCHAR (36)   NOT NULL,
    [AuditDWKey]        INT            NOT NULL,
    [SourceDatabaseKey] INT            NOT NULL,
    [ValidFrom]         DATETIME2 (0)  NOT NULL,
    [ValidTo]           DATETIME2 (0)  NOT NULL
);

