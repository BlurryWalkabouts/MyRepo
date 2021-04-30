CREATE TABLE [Lift313].[newsitem] (
    [unid]           UNIQUEIDENTIFIER NULL,
    [dataanmk]       DATETIME         NULL,
    [datwijzig]      DATETIME         NULL,
    [uidaanmk]       UNIQUEIDENTIFIER NULL,
    [uidwijzig]      UNIQUEIDENTIFIER NULL,
    [status]         INT              NULL,
    [subject]        NVARCHAR (50)    NULL,
    [newstype]       INT              NULL,
    [publish_from]   DATETIME         NULL,
    [publish_to]     DATETIME         NULL,
    [rank]           INT              NULL,
    [link_url]       NVARCHAR (250)   NULL,
    [link_title]     NVARCHAR (100)   NULL,
    [AuditDWKey]     INT              NULL
);

