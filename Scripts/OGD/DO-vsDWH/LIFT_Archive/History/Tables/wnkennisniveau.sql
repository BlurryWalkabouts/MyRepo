CREATE TABLE [History].[wnkennisniveau] (
    [unid]            UNIQUEIDENTIFIER NOT NULL,
    [werknemerid]     UNIQUEIDENTIFIER NULL,
    [itemid]          UNIQUEIDENTIFIER NULL,
    [cijfer]          INT              NULL,
    [acijfer]         INT              NULL,
    [werkervaring]    MONEY            NULL,
    [ervaring_is_eis] BIT              NULL,
    [AuditDWKey]  INT              NULL,
    [ValidFrom]       DATETIME2 (0)    NOT NULL,
    [ValidTo]         DATETIME2 (0)    NOT NULL
);

