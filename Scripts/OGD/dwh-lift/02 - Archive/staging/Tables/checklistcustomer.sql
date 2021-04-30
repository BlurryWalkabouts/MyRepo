CREATE TABLE [Staging].[checklistcustomer] (
    [unid]                      UNIQUEIDENTIFIER NULL,
    [archief]                   INT              NULL,
    [rang]                      INT              NULL,
    [tekst]                     NVARCHAR (35)    NULL,
    [showforPotentialCustomer]  INT              NULL,
    [showforCustomer]           INT              NULL,
    [afkorting]                 NVARCHAR (10)    NULL,
    [AuditDWKey]                INT              NULL
);