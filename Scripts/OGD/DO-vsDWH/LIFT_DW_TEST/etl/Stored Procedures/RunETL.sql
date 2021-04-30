CREATE PROCEDURE etl.RunETL
AS
BEGIN

-- Script: RunETL
-- Note:   Executes all other ETL scripts in order of dependency
-- Author: Pieter Simoons, may 2017
-- Review:

INSERT INTO
	etl.ProcedureLog
	(
	Batch
	, [Time]
	, Script
	, Success
	, [Message]
	)
SELECT
	Batch = COALESCE((SELECT MAX(COALESCE(Batch, 0)) + 1 FROM etl.ProcedureLog), 1)
	, [Time]= GETDATE()
	, Script = 'RunETL'
	, Success = 1
	, [Message] = 'Begin ETL procedure.'

-- Dimension tables generally have no dependencies
EXEC etl.LoadDimAccountManager
EXEC etl.LoadDimCustomer
EXEC etl.LoadDimDate
EXEC etl.LoadDimHourType
EXEC etl.LoadDimContactPerson -- Depends on Dim.Customer
EXEC etl.LoadDimProject       -- Depends on Dim.Customer
EXEC etl.LoadDimNomination    -- Depends on Dim.Project
EXEC etl.LoadDimEmployee      -- Depends on Dim.Nomination
EXEC etl.LoadDimService

-- Fact tables
EXEC etl.LoadFactHour
EXEC etl.LoadFactPlanning
EXEC etl.LoadFactPlanningHistory

-- Completed
EXEC etl.[Log] @@PROCID

END