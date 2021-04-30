CREATE EXTERNAL TABLE [archive].[planning_task_assignment] (
    [task_assignmentid] uniqueidentifier                                  NULL,
    [startdate]         datetime                                          NULL,
    [amount]            int                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'planning_task_assignment'
);
