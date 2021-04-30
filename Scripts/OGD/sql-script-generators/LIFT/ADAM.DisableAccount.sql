CREATE SCHEMA [ActiveDirectoryManagement];
GO
CREATE ROLE [ActiveDirectoryManager];
GO
GRANT SELECT ON SCHEMA::[ActiveDirectoryManagement] TO [ActiveDirectoryManager];
GO
CREATE USER [sa_ActiveDirectoryManager] WITH PASSWORD = 'poker-GK9Wmtr$LJMcT^*3P-jw3t@vrPzZCpmqcCKAXXD7VQnfseeNRAB39#Nv4uh';
GO
ALTER ROLE [ActiveDirectoryManager] ADD MEMBER [sa_ActiveDirectoryManager];
GO

ALTER VIEW [ActiveDirectoryManagement].[EmployeesDisabled] AS (
-- LIFT removes the disabled records the moment the checkmark is removed!
	SELECT 
		 [Name] = W.persnr 
		,[DateDisabled] = CEL.dataanmk
		,[Disabled] = CEL.gechecked
		,[Reason] = COALESCE(CAST(extra_info AS NVARCHAR(MAX)), '[Not Available]')
		,[DisabledBy_Code]
		,[DisabledBy_Name]
		,[DisabledBy_Desc]
	FROM dbo.ChecklistEmployeeLink CEL
	INNER JOIN dbo.werknemer W ON (W.unid = CEL.employeeid)
	LEFT JOIN (
		select 
			 [Code] = g.unid
			,[DisabledBy_Code] = w.unid
			,[DisabledBy_Name] = w.persnr
			,[DisabledBy_Desc] = g.naam
		from dbo.gebruiker g
		inner join dbo.werknemer w ON (g.employeeid = w.unid)
		where w.persnr != ''
	) G ON (G.code = CEL.gebruikerid)
	WHERE checkId = 'D51B2D1B-E80B-420A-B7ED-E74298D5D7EC'
);
GO

ALTER VIEW [ActiveDirectoryManagement].[EmployeesAuditLastModified] AS
(
	select 
		 [Name] = e.persnr
		,[DateModified] = e.datwijzig
		,[ModifiedBy_Code] = w.unid
		,[ModifiedBy_Name] = w.persnr
		,[ModifiedBy_Desc] = g.naam
	from dbo.werknemer e
	inner join dbo.gebruiker g ON (g.unid = e.uidwijzig)
	inner join dbo.werknemer w ON (g.employeeid = w.unid)
	where e.persnr != ''
);