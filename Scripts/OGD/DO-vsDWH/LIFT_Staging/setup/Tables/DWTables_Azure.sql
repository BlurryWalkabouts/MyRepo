CREATE TABLE [setup].[DWTables_Azure] (
    [id]          INT            IDENTITY (0, 1) NOT NULL,
    [TABLE_NAME]  [sysname]      NOT NULL,
    [import]      BIT            NULL,
    [comment]     NVARCHAR (MAX) NULL,
    [deleted]     BIT            NULL,
    [datecreated] DATETIME2 (0)  NULL
);

