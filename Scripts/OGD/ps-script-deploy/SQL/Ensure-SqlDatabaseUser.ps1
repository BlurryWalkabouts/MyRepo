<#
.SYNOPSIS
    Makes sure a SQL user exists in the given database
.DESCRIPTION
    A simple wrapper for MSSQL user management.

.PARAMETER UserName
    The name of the user to create.
    This can be either a fully-qualified domain name, or a reference of the form SERVER\INSTANCE.
.PARAMETER LoginName
    The name of the login to map.
    If the specified login does not exist but InitialPassword is supplied, a SQL login with the specified password
    will be created.
    If not given, and no InitialUserPassword is supplied, the LoginName is assumed to be equal to the UserName.
.PARAMETER InitialPassword
    The password to use when creating the user or login.
    If the user/login already exists, the password is not overwritten.
    If no LoginName is supplied, a contained user will be created.
.PARAMETER ServerName
    The name of the server to deploy to.
    This can be either a fully-qualified domain name, or a reference of the form SERVER\INSTANCE.
.PARAMETER Database
    The name of the database to deploy to. The database must already exist.
.PARAMETER SqlCredentials
    A PSCredential object to use as authorization. If not provided, integrated authentication (SSPI) is used.
.PARAMETER ConnectionString
    The full connectionstring to use.
.PARAMETER DatabaseRole
    A list of database roles.
    The user will be added to the specified database roles.
    Existing memberships will not be removed.
.NOTES
    Author     : Arno Schuring (arno.schuring@ogd.nl)
.LINK
    https://ogd.visualstudio.com/Data%20Office/_git/ps-script-deploy
#>

[cmdletbinding()]
param(
    [parameter(mandatory=$true)]
    [String] $UserName,
    [parameter(mandatory=$false)]
    [String] $LoginName = $null,
    [parameter(mandatory=$false)]
    [SecureString] $InitialPassword = $null,
    [parameter(parametersetname="UseConnectionString", mandatory=$true)]
    [String] $ConnectionString,
    [parameter(parametersetname="UseConnectionComponents", mandatory=$true)]
    [String] $ServerName,
    [parameter(parametersetname="UseConnectionComponents", mandatory=$true)]
    [String] $Database,
    [parameter(parametersetname="UseConnectionComponents", mandatory=$false)]
    [PSCredential] $SqlCredentials = $null,
    [parameter(mandatory=$false)]
    [String[]] $DatabaseRole = @()
)

#Requires -Version 3
#Requires -Modules InvokeQuery

#region parameter parsing
switch($PSCmdlet.ParameterSetName) {
    "UseConnectionString" {
        $commonQueryParameters = @{
            ConnectionString = $ConnectionString
        }
    }
    "UseConnectionComponents" {
        $commonQueryParameters = @{
            Server = $ServerName
            Database = $Database
        }
        if ($SqlCredentials) {
            $CommonQueryParameters.Add('Credential', $SqlCredentials)
         }
    }
}
#endregion

#region initial checking
# abort the script if the first query fails
try {
    $ExistingUsers = (Invoke-SqlServerQuery -Verbose @CommonQueryParameters -ErrorAction Stop `
            -Sql 'SELECT [name] FROM [sys].[database_principals];') | Select-Object -ExpandProperty 'name'
} catch {
    Throw
}
#endregion

if ($UserName -notin $ExistingUsers) {
    Write-Output "Creating user ${UserName}"
    if ($InitialPassword -eq $null) {
        if (-not $LoginName) {
            $query = "CREATE USER [${UserName}] FOR LOGIN [${UserName}];"
        } else {
            $query = "CREATE USER [${UserName}] FOR LOGIN [${LoginName}];"
        }
    } else {
        $rawPassword = (New-Object -TypeName PSCredential -ArgumentList "dummy",$InitialPassword).GetNetworkCredential().Password
        # double-escape single quotes in password because of SQL
        $rawPassword = $rawPassword -replace "'", "''"
        if (-not $LoginName) {
            $query = "CREATE USER [${UserName}] WITH PASSWORD='${rawPassword}';"
        } else {
            $query = @"
                CREATE LOGIN [${LoginName}] WITH PASSWORD='${rawPassword}';
                CREATE USER [${UserName}] FOR LOGIN [${LoginName}];
"@
        }
    }
    $null = Invoke-SqlServerQuery @CommonQueryParameters -Verbose -CUD -Sql $query -ErrorAction Stop
}

foreach ($Role in $DatabaseRole) {
    Write-Output "Adding user to role ${Role}"
    $query = "ALTER ROLE [${Role}] ADD MEMBER [${UserName}];"
    $null = Invoke-SqlServerQuery @CommonQueryParameters -Verbose -CUD -Sql $query
}
