CREATE TABLE [History].[acquisition_goal] (
    [unid]                    UNIQUEIDENTIFIER NOT NULL,
    [archief]                 INT              NULL,
    [rang]                    INT              NULL,
    [tekst]                   NVARCHAR (30)    NULL,
    [afkorting]               NVARCHAR (10)    NULL,
    [klant1_visible]          BIT              NULL,
    [klant2_visible]          BIT              NULL,
    [contactpersoon1_visible] BIT              NULL,
    [project_visible]         BIT              NULL,
    [AuditDWKey]          INT              NULL,
    [ValidFrom]               DATETIME2 (0)    NOT NULL,
    [ValidTo]                 DATETIME2 (0)    NOT NULL
);

