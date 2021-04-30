CREATE TABLE [Staging].[contactnotecustomer] (
    [unid]               UNIQUEIDENTIFIER NULL,
    [dataanmk]           DATETIME2(0)     NULL,
    [datwijzig]          DATETIME2(0)     NULL,
    [uidaanmk]           UNIQUEIDENTIFIER NULL,
    [uidwijzig]          UNIQUEIDENTIFIER NULL,
    [customerid]         UNIQUEIDENTIFIER NULL,
    [customercontactid]  UNIQUEIDENTIFIER NULL,
    [conversationdate]   DATETIME2(0)     NULL,
    [typeid]             UNIQUEIDENTIFIER NULL,
    [type]               NVARCHAR(60)     NULL,
    [categorieid]        UNIQUEIDENTIFIER NULL,
    [categorie]          NVARCHAR(25)     NULL,
    [acquisition_goalid] UNIQUEIDENTIFIER NULL,
    [acquisition_goal]   NVARCHAR(30)     NULL,
    [AuditDWKey]         INT              NULL
);