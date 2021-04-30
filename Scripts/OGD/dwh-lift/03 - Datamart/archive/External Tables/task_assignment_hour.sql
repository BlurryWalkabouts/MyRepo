CREATE EXTERNAL TABLE [archive].[task_assignment_hour] (
    [unid]              uniqueidentifier                                  NOT NULL,
    [datwijzig]         datetime                                          NULL,
    [old_amount]        money                                             NULL,
    [datum]             datetime                                          NULL,
    [task_assignmentid] uniqueidentifier                                  NULL,
    [seconds]           bigint                                            NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'task_assignment_hour'
);
