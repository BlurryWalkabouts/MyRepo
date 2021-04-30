CREATE TABLE [Staging].[checklistcustomerlink] (
    [unid]                  UNIQUEIDENTIFIER NULL,
    [checkid]               UNIQUEIDENTIFIER NULL,
    [customerid]            UNIQUEIDENTIFIER NULL,
    [gebruikerid]           UNIQUEIDENTIFIER NULL,
    [gechecked]             BIT              NULL,
    [dataanmk]              DATETIME2(0)     NULL,
    [AuditDWKey]            INT              NULL
);