CREATE PROCEDURE [Load].[PostLoadDatamart]
AS

BEGIN

/********************************************************************************
Insert the last load date of LiftDW into Log.LastLoad
********************************************************************************/

DELETE FROM [Log].LastLoad

PRINT 'Inserting last load date into Log.LastLoad'
INSERT INTO [Log].LastLoad DEFAULT VALUES

/* Reset all customer to inactive */

UPDATE Dim.Customer
SET CustomerActive = 0

/* Set active customer */

UPDATE Dim.Customer
SET CustomerActive = 1
WHERE CustomerKey IN (SELECT CustomerKey FROM Dim.Project WHERE ProjectStatus = 2 GROUP BY CustomerKey)

/********************************************************************************
Recreate the FK`s
********************************************************************************/

PRINT 'Create foreign keys'
EXEC [Load].EnableForeignKeys

/********************************************************************************
Assign the permissions
********************************************************************************/

EXEC [Load].LoadRolePermissions
EXEC [Load].AssignRolePermissions

END