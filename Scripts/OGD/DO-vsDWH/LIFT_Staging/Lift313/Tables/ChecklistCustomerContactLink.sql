CREATE TABLE [Lift313].[ChecklistCustomerContactLink] (
    [unid]              UNIQUEIDENTIFIER NULL,
    [checkid]           UNIQUEIDENTIFIER NULL,
    [customercontactid] UNIQUEIDENTIFIER NULL,
    [gebruikerid]       UNIQUEIDENTIFIER NULL,
    [gechecked]         BIT              NULL,
    [dataanmk]          DATETIME         NULL,
    [extra_info]        NVARCHAR (MAX)   NULL,
    [AuditDWKey]    INT              NULL
);

