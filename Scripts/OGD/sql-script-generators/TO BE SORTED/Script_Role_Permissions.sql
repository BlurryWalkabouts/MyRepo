declare @RoleName varchar(50) = 'FullAccess'

declare @Script varchar(max) = 'CREATE ROLE ' + @RoleName + char(13)

select @script = @script + 'GRANT ' + prm.permission_name + ' ON ' + OBJECT_SCHEMA_NAME(major_id) + '.' + OBJECT_NAME(major_id) + ' TO ' + rol.name +';' + char(13) COLLATE Latin1_General_CI_AS
--select * 
from sys.database_permissions prm

    join sys.database_principals rol on

        prm.grantee_principal_id = rol.principal_id

where rol.name = @RoleName

print @script

