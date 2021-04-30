CREATE PROCEDURE [Security].[GenerateSuffixMapping]
AS
SET NOCOUNT ON
	
-- This sproc inserts defaults groups

-- Clear up existing mappings
-- Using delete because of future replication
DELETE FROM [Security].UserPrincipalNameSuffix
DELETE FROM [Security].UserPrincipalNameSuffixMapping

-- Resetting seed
DBCC CHECKIDENT ('Security.UserPrincipalNameSuffix', RESEED, 1)
DBCC CHECKIDENT ('Security.UserPrincipalNameSuffixMapping', RESEED, 1)

-- Inserting suffix list
INSERT INTO [Security].UserPrincipalNameSuffix ([Name])
SELECT Suffix
FROM [Security].cpToSuffix

-- Inserting Mappings
INSERT INTO [Security].UserPrincipalNameSuffixMapping (UserPrincipalNameSuffixID, CustomerKey)
SELECT S.ID, C.CustomerKey
FROM [Security].UserPrincipalNameSuffix S
INNER JOIN [Security].cpToSuffix C ON (C.Suffix = S.[Name])

RETURN 0