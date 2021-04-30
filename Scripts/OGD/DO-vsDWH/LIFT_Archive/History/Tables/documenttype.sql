CREATE TABLE [History].[documenttype] (
    [unid]               UNIQUEIDENTIFIER NOT NULL,
    [doccode2]           NVARCHAR (12)    NULL,
    [sjabloonnaam]       NVARCHAR (MAX)   NULL,
    [mailing]            BIT              NULL,
    [archiefid]          UNIQUEIDENTIFIER NULL,
    [magimporteren]      BIT              NULL,
    [islastig]           BIT              NULL,
    [icoon]              NVARCHAR (20)    NULL,
    [archieficoon]       NVARCHAR (20)    NULL,
    [afkorting]          NVARCHAR (10)    NULL,
    [templateformat]     INT              NULL,
    [documentcategoryid] UNIQUEIDENTIFIER NULL,
    [importonly]         BIT              NULL,
    [locale]             NVARCHAR (10)    NULL,
    [AuditDWKey]     INT              NULL,
    [ValidFrom]          DATETIME2 (0)    NOT NULL,
    [ValidTo]            DATETIME2 (0)    NOT NULL
);

