CREATE TABLE [History].[license_time] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [userid]         UNIQUEIDENTIFIER NULL,
    [license_key]    INT              NULL,
    [logindate]      DATETIME         NULL,
    [logoutdate]     DATETIME         NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

