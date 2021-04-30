--EXEC sp_get_distributor;

DECLARE @DistributionDB sysname = 'distribution';

USE [master];
EXEC sp_adddistributor @distributor = @@SERVERNAME;
EXEC sp_adddistributiondb @database = @DistributionDB, @security_mode = 1;
EXEC sp_adddistpublisher @publisher = @@SERVERNAME, @distribution_db = @DistributionDB;
