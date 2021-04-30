CREATE TABLE [Anywhere365_UCC].[UCC_Name] (
    [id]            BIGINT        NULL,
    [name]          VARCHAR (255) NULL,
    [Latitude]      VARCHAR (50)  NULL,
    [Longitude]     VARCHAR (50)  NULL,
    [DWDateCreated] DATETIME      CONSTRAINT [DF_UCC_CallName_DWDateCreated] DEFAULT (getdate()) NOT NULL
);

