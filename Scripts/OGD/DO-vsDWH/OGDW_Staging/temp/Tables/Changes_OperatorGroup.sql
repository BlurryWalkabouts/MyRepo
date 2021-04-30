CREATE TABLE [temp].[Changes_OperatorGroup] (
    [OperatorGroup]     NVARCHAR (255) NULL,
    [SourceDatabaseKey] INT            NOT NULL,
    [ChangedAt]         DATETIME       NULL,
    [OG_ID]             INT            NULL,
    [T2_Known]          BIT            NOT NULL,
    [T2_keyNumber]      BIGINT         NULL,
    [T2_RN]             INT            NULL,
    [T2_RNdesc]         INT            NULL,
    [AuditDWKey]        INT            NOT NULL
);

