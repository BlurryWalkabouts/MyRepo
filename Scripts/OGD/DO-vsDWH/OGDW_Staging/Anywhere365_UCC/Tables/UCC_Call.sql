CREATE TABLE [Anywhere365_UCC].[UCC_Call] (
    [id]            BIGINT        NULL,
    [time]          DATETIME      NULL,
    [caller]        VARCHAR (255) NULL,
    [correlationid] VARCHAR (50)  NULL,
    [ucc_id]        BIGINT        NULL,
    [DWDateCreated] DATETIME      CONSTRAINT [DF_UCC_Call_DWDateCreated] DEFAULT (getdate()) NOT NULL
);




GO
CREATE NONCLUSTERED INDEX [IX_UCCCall_ucc_id]
    ON [Anywhere365_UCC].[UCC_Call]([ucc_id] ASC)
    INCLUDE([correlationid]);


GO
CREATE NONCLUSTERED INDEX [IX_UCCCall_correlationid_NCinclude]
    ON [Anywhere365_UCC].[UCC_Call]([correlationid] ASC)
    INCLUDE([caller], [ucc_id]) WITH (FILLFACTOR = 80);

