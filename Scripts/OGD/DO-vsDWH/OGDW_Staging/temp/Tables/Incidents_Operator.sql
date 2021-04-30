CREATE TABLE [temp].[Incidents_Operator] (
    [OperatorName]      NVARCHAR (255) NOT NULL,
    [SourceDatabaseKey] INT            NOT NULL,
    [ChangedAt]         DATETIME       NULL,
    [OP_ID]             INT            NULL,
    [T2_Known]          BIT            NOT NULL,
    [T2_keyNumber]      BIGINT         NULL,
    [T2_RN]             INT            NULL,
    [T2_RNdesc]         INT            NULL,
    [AuditDWKey]        INT            NOT NULL
);



