CREATE PROCEDURE [Security].[GenerateUserPrincipalNameMapping]
AS

SET NOCOUNT ON
	
-- This sproc inserts defaults groups

-- Clear up existing mappings
-- Using delete because of future replication
DELETE FROM [Security].UserPrincipalName

-- Resetting seed
DBCC CHECKIDENT ('Security.UserPrincipalName', RESEED, 1)

RETURN 0