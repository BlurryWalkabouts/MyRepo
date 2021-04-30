CREATE EXTERNAL TABLE [archive].[task_hour] (
    [unid]       uniqueidentifier                                  NOT NULL,
    [datwijzig]  datetime                                          NULL,
    [old_amount] money                                             NULL,
    [datum]      datetime                                          NULL,
    [taskid]     uniqueidentifier                                  NULL,
    [employeeid] uniqueidentifier                                  NULL,
    [seconds]    bigint                                            NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'task_hour'
);
