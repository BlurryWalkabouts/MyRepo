-- Enable advanced options 
EXEC sp_configure 'show advanced options', 1
GO
-- Update the currently configured value for advanced options.
RECONFIGURE
GO

-- Enable the feature
EXEC sp_configure 'xp_cmdshell', 1
GO
-- Update the currently configured value for this feature.
RECONFIGURE
GO