CREATE TABLE [History].[assignment_declaration_link] (
    [unid]              UNIQUEIDENTIFIER NOT NULL,
    [assignmentid]      UNIQUEIDENTIFIER NULL,
    [budget]            MONEY            NULL,
    [budget_categoryid] UNIQUEIDENTIFIER NULL,
    [declarationid]     UNIQUEIDENTIFIER NULL,
    [AuditDWKey]    INT              NULL,
    [ValidFrom]         DATETIME2 (0)    NOT NULL,
    [ValidTo]           DATETIME2 (0)    NOT NULL
);

