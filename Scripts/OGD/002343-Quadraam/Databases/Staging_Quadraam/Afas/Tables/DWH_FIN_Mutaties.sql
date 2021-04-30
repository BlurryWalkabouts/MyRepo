CREATE TABLE [Afas].[DWH_FIN_Mutaties] (
    [Bedrag_debet]      DECIMAL (26, 10) NULL,
    [Description]       NVARCHAR (120)   NULL,
    [Created]           DATETIME2 (0)    NULL,
    [UnitId]            INT              NULL,
    [EntryNo]           INT              NULL,
    [SeqNo]             INT              NULL,
    [JournalId]         NVARCHAR (6)     NULL,
    [AccountNo]         NVARCHAR (16)    NULL,
    [AmtDebit]          DECIMAL (26, 10) NULL,
    [AmtCredit]         DECIMAL (26, 10) NULL,
    [EntryDate]         DATETIME2 (0)    NULL,
    [InvoiceId]         NVARCHAR (12)    NULL,
    [VoucherDate]       DATETIME2 (0)    NULL,
    [VoucherNo]         NVARCHAR (32)    NULL,
    [Year]              INT              NULL,
    [Period]            INT              NULL,
    [VatCode]           NVARCHAR (3)     NULL,
    [VatAmt]            DECIMAL (26, 10) NULL,
    [Modified]          DATETIME2 (0)    NULL,
    [Link_naar_factuur] NVARCHAR (250)   NULL,
    [Type]              NVARCHAR (100)   NULL,
    [Collect_On]        NVARCHAR (100)   NULL,
    [Omschrijving]      NVARCHAR (50)    NULL,
    [DimAx1]            NVARCHAR (16)    NULL,
    [DimAx2]            NVARCHAR (16)    NULL,
    [DimAx3]            NVARCHAR (16)    NULL,
    [DimAx4]            NVARCHAR (16)    NULL,
    [DimAx5]            NVARCHAR (16)    NULL
);



