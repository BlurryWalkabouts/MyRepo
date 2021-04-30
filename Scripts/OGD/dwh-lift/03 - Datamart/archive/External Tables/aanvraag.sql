CREATE EXTERNAL TABLE [archive].[aanvraag] (
    [unid]                  uniqueidentifier                                  NOT NULL,
    [dataanmk]              datetime                                          NULL,
    [datwijzig]             datetime                                          NULL,
    [status]                int                                               NULL,
    [archiefdatum]          datetime                                          NULL,
    [projectid]             uniqueidentifier                                  NULL,
    [aanvraagnr]            nvarchar(20)                                      NULL,
    [slagingspercentage]    int                                               NULL,
    [amount_quoted]         money                                             NULL,
    [datacceptatie]         datetime                                          NULL,
    [is_additional_request] bit                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'aanvraag'
);
