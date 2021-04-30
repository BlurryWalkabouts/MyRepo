CREATE TABLE [History].[ChecklistEmployeeLink] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [checkid]        UNIQUEIDENTIFIER NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [gechecked]      BIT              NULL,
    [dataanmk]       DATETIME         NULL,
    [extra_info]     NVARCHAR (MAX)   NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

