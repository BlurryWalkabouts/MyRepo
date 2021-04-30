CREATE TABLE [History].[ChecklistCustomerContactLink] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [checkid]           UNIQUEIDENTIFIER NULL,
    [customercontactid] UNIQUEIDENTIFIER NULL,
    [gebruikerid]       UNIQUEIDENTIFIER NULL,
    [gechecked]         BIT              NULL,
    [dataanmk]          DATETIME         NULL,
    [extra_info]        NVARCHAR (MAX)   NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);

