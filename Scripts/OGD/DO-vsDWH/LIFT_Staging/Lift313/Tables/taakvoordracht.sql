CREATE TABLE [Lift313].[taakvoordracht] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [status]         INT              NULL,
    [taakid]         UNIQUEIDENTIFIER NULL,
    [type]           INT              NULL,
    [startdatum]     DATETIME         NULL,
    [einddatum]      DATETIME         NULL,
    [inkoopprijs]    MONEY            NULL,
    [werklast]       INT              NULL,
    [budget]         INT              NULL,
    [vrijvelda]      NVARCHAR (40)    NULL,
    [afkorting]      NVARCHAR (10)    NULL,
    [employeeid]     UNIQUEIDENTIFIER NULL,
    [AuditDWKey]     INT              NULL
);

