CREATE TABLE [History].[checklistcustomerlink] (
    [unid]                       UNIQUEIDENTIFIER NOT NULL,
    [checkid]                    UNIQUEIDENTIFIER NULL,
    [customerid]                 UNIQUEIDENTIFIER NULL,
    [gebruikerid]                UNIQUEIDENTIFIER NULL,
    [gechecked]                  BIT              NULL,
    [dataanmk]                   DATETIME2(0)     NULL,
    [AuditDWKey]                 INT              NULL,
    [ValidFrom]                  DATETIME2 (0)    NOT NULL,
    [ValidTo]                    DATETIME2 (0)    NOT NULL
);