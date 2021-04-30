CREATE TABLE [temp].[Changes_Caller] (
    [CallerBranch]          NVARCHAR (255) NULL,
    [CallerEmail]           NVARCHAR (255) NOT NULL,
    [CallerName]            NVARCHAR (255) NOT NULL,
    [CallerTelephoneNumber] NVARCHAR (255) NOT NULL,
    [Department]            NVARCHAR (255) NULL,
    [SourceDatabaseKey]     INT            NOT NULL,
    [ChangedAt]             DATETIME       NULL,
    [CA_ID]                 INT            NULL,
    [T2_Known]              BIT            NOT NULL,
    [T2_keyNumber]          BIGINT         NULL,
    [T2_RN]                 INT            NULL,
    [T2_RNdesc]             INT            NULL,
    [AuditDWKey]            INT            NOT NULL
);



