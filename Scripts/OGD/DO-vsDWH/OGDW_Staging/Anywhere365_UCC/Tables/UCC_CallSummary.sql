CREATE TABLE [Anywhere365_UCC].[UCC_CallSummary] (
    [id]            BIGINT        NULL,
    [correlationid] VARCHAR (50)  NULL,
    [starttime]     DATETIME      NULL,
    [inqueuetime]   DATETIME      NULL,
    [acceptedtime]  DATETIME      NULL,
    [endtime]       DATETIME      NULL,
    [accepted]      BIT           NULL,
    [queuetime]     BIGINT        NULL,
    [skillChosen]   VARCHAR (50)  NULL,
    [initialAgent]  VARCHAR (255) NULL,
    [handled]       BIT           NULL,
    [mcRemoved]     BIT           NULL,
    [DWDateCreated] DATETIME      CONSTRAINT [DF_UCC_CallSummary_DWDateCreated] DEFAULT (getdate()) NOT NULL
);




GO
CREATE UNIQUE CLUSTERED INDEX [PK_CallSummary_correlationid]
    ON [Anywhere365_UCC].[UCC_CallSummary]([correlationid] ASC);


GO
CREATE NONCLUSTERED INDEX [IX_UCC_CallSummary_skillChosen_NCinclude]
    ON [Anywhere365_UCC].[UCC_CallSummary]([skillChosen] ASC)
    INCLUDE([starttime], [inqueuetime], [endtime], [accepted], [queuetime], [initialAgent], [handled], [DWDateCreated]) WITH (FILLFACTOR = 80);


GO
CREATE NONCLUSTERED INDEX [IX_UCC_CallSummary_endtime_NCinclude]
    ON [Anywhere365_UCC].[UCC_CallSummary]([endtime] ASC)
    INCLUDE([id], [correlationid], [starttime], [inqueuetime], [acceptedtime], [queuetime], [skillChosen], [initialAgent], [handled], [DWDateCreated]) WITH (FILLFACTOR = 80);

