CREATE PROCEDURE [etl].[CorrectCasings]
AS

EXEC etl.CorrectCasing 'Dim', 'OperatorGroup', 'OperatorGroup'
/*
EXEC etl.CorrectCasing 'Dim', 'Caller', 'CallerBranch'
EXEC etl.CorrectCasing 'Fact', 'Call', 'initialAgent'
EXEC etl.CorrectCasing 'Fact', 'Change', 'Coordinator'
EXEC etl.CorrectCasing 'Fact', 'Change', 'SubCategory'
EXEC etl.CorrectCasing 'Fact', 'Change', 'Template'
EXEC etl.CorrectCasing 'Fact', 'Incident', 'StandardSolution'
EXEC etl.CorrectCasing 'Fact', 'Incident', 'SubCategory'
EXEC etl.CorrectCasing 'Fact', 'Incident', 'ObjectID'
EXEC etl.CorrectCasing 'Fact', 'Change', 'ObjectID'
*/
/*
EXEC etl.CorrectCasings
*/