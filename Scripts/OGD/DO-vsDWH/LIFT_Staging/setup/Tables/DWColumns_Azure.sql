CREATE TABLE [setup].[DWColumns_Azure] (
    [id]               INT            IDENTITY (0, 1) NOT NULL,
    [TABLE_NAME]       [sysname]      NOT NULL,
    [COLUMN_NAME]      [sysname]      NOT NULL,
    [column_fulltype]  VARCHAR (MAX)  NULL,
    [ordinal_position] INT            NULL,
    [import]           BIT            NULL,
    [keep_history]     BIT            NULL,
    [compare]          BIT            NULL,
    [comment]          NVARCHAR (MAX) NULL,
    [deleted]          BIT            NULL,
    [datecreated]      DATETIME2 (0)  NULL
);

