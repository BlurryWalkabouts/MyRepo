CREATE TABLE [Lift313].[factuurregel] (
    [unid]                UNIQUEIDENTIFIER NULL,
    [voordrachtid]        UNIQUEIDENTIFIER NULL,
    [artikelvdid]         UNIQUEIDENTIFIER NULL,
    [vrijproductid]       UNIQUEIDENTIFIER NULL,
    [inkoopid]            UNIQUEIDENTIFIER NULL,
    [projectid]           UNIQUEIDENTIFIER NULL,
    [factuurid]           UNIQUEIDENTIFIER NULL,
    [voordrachttype]      INT              NULL,
    [bedrag]              MONEY            NULL,
    [bijgeboekt]          MONEY            NULL,
    [grootboekid]         UNIQUEIDENTIFIER NULL,
    [btwid]               UNIQUEIDENTIFIER NULL,
    [productid]           UNIQUEIDENTIFIER NULL,
    [uurlastenid]         UNIQUEIDENTIFIER NULL,
    [factuurplanningid]   UNIQUEIDENTIFIER NULL,
    [verwerktaccountview] INT              NULL,
    [AuditDWKey]      INT              NULL
);

