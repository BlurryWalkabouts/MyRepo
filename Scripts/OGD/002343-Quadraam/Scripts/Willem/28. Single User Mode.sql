USE master
GO

DBCC OPENTRAN()

-- https://docs.microsoft.com/en-us/sql/relational-databases/databases/set-a-database-to-single-user-mode
ALTER DATABASE Staging_Quadraam SET SINGLE_USER WITH ROLLBACK IMMEDIATE
GO
ALTER DATABASE Staging_Quadraam SET MULTI_USER
GO

--Nonqualified transactions are being rolled back. Estimated rollback completion: 0%.