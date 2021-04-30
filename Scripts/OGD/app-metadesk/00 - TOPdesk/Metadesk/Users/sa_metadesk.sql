DROP USER IF EXISTS [sa_metadesk];
GO

CREATE USER [sa_metadesk] WITH PASSWORD=N'$SaMetadeskPassword';
GO

ALTER ROLE [metadesk] ADD MEMBER [sa_metadesk];
GO