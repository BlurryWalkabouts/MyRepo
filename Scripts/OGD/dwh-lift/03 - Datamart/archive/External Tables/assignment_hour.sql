CREATE EXTERNAL TABLE [archive].[assignment_hour] (
    [unid]               uniqueidentifier                                  NOT NULL,
    [datwijzig]          datetime                                          NULL,
    [old_amount]         money                                             NULL,
    [datum]              datetime                                          NULL,
    [verwerkt_factuur]   bit                                               NULL,
    [seen_by_invoice_id] uniqueidentifier                                  NULL,
    [hourtypeid]         uniqueidentifier                                  NULL,
    [assignmentid]       uniqueidentifier                                  NULL,
    [seconds]            bigint                                            NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'assignment_hour'
);
