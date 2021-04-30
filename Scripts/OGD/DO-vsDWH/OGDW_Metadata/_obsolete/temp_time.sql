CREATE TABLE [setup].[temp_time] (
    [TimeKey]               INT            NULL,
    [minute_of_day]         INT            NULL,
    [hour_of_day_24]        DECIMAL (38)   NULL,
    [hour_of_day_12]        DECIMAL (38)   NULL,
    [am_pm]                 NVARCHAR (100) NULL,
    [minute_of_hour]        DECIMAL (38)   NULL,
    [half_hour]             DECIMAL (38)   NULL,
    [half_hour_of_day]      DECIMAL (38)   NULL,
    [quarter_hour]          DECIMAL (38)   NULL,
    [quarter_hour_of_day]   DECIMAL (38)   NULL,
    [Time_half_hour_of_day] TIME (0)       NULL
);

