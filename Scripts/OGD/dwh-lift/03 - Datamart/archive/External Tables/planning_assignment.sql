CREATE EXTERNAL TABLE [archive].[planning_assignment] (
    [assignmentid] uniqueidentifier                                  NULL,
    [startdate]    datetime                                          NULL,
    [amount]       int                                               NULL
)
WITH (
    DATA_SOURCE = [lift-archive],
    SCHEMA_NAME = N'dbo',
    OBJECT_NAME = N'planning_assignment'
);
