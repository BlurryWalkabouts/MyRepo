CREATE TABLE [Lift313].[ChecklistEmployeeLink] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [checkid]        UNIQUEIDENTIFIER NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [gebruikerid]    UNIQUEIDENTIFIER NULL,
    [gechecked]      BIT              NULL,
    [dataanmk]       DATETIME         NULL,
    [extra_info]     NVARCHAR (MAX)   NULL,
    [AuditDWKey]     INT              NULL
);

