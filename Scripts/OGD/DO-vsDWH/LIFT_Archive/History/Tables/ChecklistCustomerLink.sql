CREATE TABLE [History].[ChecklistCustomerLink] (
    [unid]           UNIQUEIDENTIFIER NOT NULL,
    [checkid]        UNIQUEIDENTIFIER NULL,
    [customerid]     UNIQUEIDENTIFIER NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [gechecked]      BIT              NULL,
    [dataanmk]       DATETIME         NULL,
    [AuditDWKey] INT              NULL,
    [ValidFrom]      DATETIME2 (0)    NOT NULL,
    [ValidTo]        DATETIME2 (0)    NOT NULL
);

