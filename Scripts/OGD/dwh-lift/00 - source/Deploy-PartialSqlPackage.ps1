<#
.SYNOPSIS
    Perform a partial DACPAC deploy
.DESCRIPTION
    A lightweight alternative to SqlPackage.exe /Action:publish

    Only supports non-data elements (views, stored procedures), since they can be redeployed without performing
    extensive data manipulation. If you need these manipulations, use the official tools provided by Microsoft.
    Existing objects are never dropped; to remove existing objects, put a DROP IF EXISTS statement in the
    corresponding file.

    The source data must be organized the same way that Sql Server Data Tools does:
    <schema>\<object type>\<object name>.sql
.PARAMETER ServerName
    The name of the server to deploy to.
    This can be either a fully-qualified domain name, or a reference of the form SERVER\INSTANCE.
.PARAMETER Database
    The name of the database to deploy to. The database must already exist.
.PARAMETER SqlCredentials
    A PSCredential object to use as authorization. If not provided, integrated authentication (SSPI) is used.
.PARAMETER Schema
    A list of schemas to process.
.NOTES
    Author     : Arno Schuring (arno.schuring@ogd.nl)
.LINK
    https://code.ogdsoftware.nl/SQL/ogd-security-lift/tree/master
#>

[cmdletbinding()]
param(
    [parameter(mandatory=$true)]
    [String] $ConnectionString,
    [String[]] $Schema = @('dwh', 'padap', 'aanvragen_ogd_nl')
)

#Requires -Version 3
#Requir -Modules InvokeQuery

Import-Module -Name "InvokeQuery"

Write-Output "Length of ConnString: $($ConnectionString.Length)"

#region inventory current database state
<#
$commonQueryParameters = @{
    Server = $ServerName
    Database = $Database
}
if ($SqlCredentials) {
    $commonQueryParameters.Add('Credential', $SqlCredentials)
}
#>
# Code to facilitate a connection string
$commonQueryParameters = @{
    ConnectionString = $ConnectionString
}

# abort the script if the first query fails
try {
    $ExistingSchemas = (Invoke-SqlServerQuery -Verbose -ConnectionString $ConnectionString -ErrorAction Stop `
            -Sql 'SELECT [name] FROM [sys].[schemas];') | Select-Object -ExpandProperty 'name'
} catch {
    Throw
}

$ExistingObjects = @'
    SELECT o.[name], o.[type], s.[name] AS [schema]
    FROM [sys].[objects] o
	    INNER JOIN [sys].[schemas] s
	    ON s.[schema_id] = o.[schema_id]
    WHERE o.[is_ms_shipped] = 0
	    AND o.[type] IN ('V', 'U', 'P');
'@ | Invoke-SqlServerQuery -ConnectionString $ConnectionString

$ExistingPrincipals = @'
    SELECT p.[name], p.[type]
    FROM [sys].[database_principals] p
    WHERE p.[type] IN ('R', 'S', 'E', 'X');
'@ | Invoke-SqlServerQuery -ConnectionString $ConnectionString
#endregion


foreach ($SchemaName in $Schema) {
Write-Output "Updating schema ${SchemaName}"
$SchemaBaseDir = Join-Path -Path $PSScriptRoot -ChildPath $SchemaName

if ($SchemaName -notin $ExistingSchemas) {
    $SchemaFile = Get-Item -LiteralPath (Join-Path -Path $SchemaBaseDir -ChildPath 'schema.sql') -ErrorAction Ignore
    if ($SchemaFile) {
        Write-Output "Using schema file $($SchemaFile.Name)"
        $query = Get-Content -LiteralPath $SchemaFile.FullName -Raw
    } else {
        Write-Output "Using default schema layout"
        # create schema, and default roles for accessing this schema
        $query = @"
            CREATE SCHEMA [${SchemaName}] AUTHORIZATION [dbo];
            GO

            CREATE ROLE [${SchemaName}_datareader] AUTHORIZATION [dbo];
            GRANT SELECT ON schema::[${SchemaName}] TO [${SchemaName}_datareader];

            CREATE ROLE [${SchemaName}_datawriter] AUTHORIZATION [dbo];
            GRANT INSERT,UPDATE,DELETE ON schema::[${SchemaName}] TO [${SchemaName}_datawriter];

            CREATE ROLE [${SchemaName}_ddladmin] AUTHORIZATION [dbo];
            GRANT ALTER ON schema::[${SchemaName}] TO [${SchemaName}_ddladmin];
            GRANT CREATE TABLE TO [${SchemaName}_ddladmin];
            GRANT CREATE VIEW TO [${SchemaName}_ddladmin];
            GRANT CREATE FUNCTION TO [${SchemaName}_ddladmin];
            GRANT CREATE PROCEDURE TO [${SchemaName}_ddladmin];
            GRANT VIEW DEFINITION ON schema::[${SchemaName}] TO [${SchemaName}_ddladmin];
"@
    }
    # Invoke-SqlServerQuery can't handle multiple batch statements, so split them before issuing
    $null = ($query -split '\n\s*GO\s*\n') | Foreach-Object { Invoke-SqlServerQuery -ConnectionString $ConnectionString -CUD -Sql $_ }
}



$ExistingViews = $ExistingObjects | Where-Object { $_.type -eq 'V ' -and $_.schema -eq $SchemaName } | Select-Object -ExpandProperty 'name'
foreach ($view in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $SchemaBaseDir -ChildPath 'Views') -File -Filter '*.sql')) {
    $ViewName = $view.BaseName
    $query = Get-Content -LiteralPath $view.FullName -Raw
    if ($ViewName -in $ExistingViews) {
        $query = $query -replace '^CREATE ', 'ALTER '
    }
    Write-Output "Updating view ${ViewName}"
    $null = Invoke-SqlServerQuery -ConnectionString $ConnectionString -CUD -Sql $query
}


$ExistingProcedures = $ExistingObjects | Where-Object { $_.type -eq 'P ' -and $_.schema -eq $SchemaName } | Select-Object -ExpandProperty 'name'
foreach ($sproc in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $SchemaBaseDir -ChildPath 'Stored Procedures') -File -Filter '*.sql')) {
    $sprocName = $sproc.BaseName
    $query = Get-Content -LiteralPath $sproc.FullName -Raw
    if ($sprocName -in $ExistingProcedures) {
        $query = $query -replace '^CREATE ', 'ALTER '
    }
    Write-Output "Updating stored procedure ${sprocName}"
    $null = Invoke-SqlServerQuery -ConnectionString $ConnectionString -CUD -Sql $query
}


$ExistingRoles = $ExistingPrincipals | Where-Object { $_.type -eq 'R' } | Select-Object -ExpandProperty 'name'
foreach ($role in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $SchemaBaseDir -ChildPath 'Roles') -File -Filter '*.sql')) {
    if ($role.BaseName -notin $ExistingRoles) {
        $query = Get-Content -LiteralPath $role.FullName -Raw
        Write-Output "Creating database role $($role.Name)"
        $null = Invoke-SqlServerQuery -ConnectionString $ConnectionString -CUD -Sql $query
    }
}


$ExistingEUsers = $ExistingPrincipals | Where-Object { $_.type -eq 'E' -or $_.type -eq 'X' } | Select-Object -ExpandProperty 'name'
foreach ($euser in (Get-ChildItem -ErrorAction Ignore -LiteralPath (Join-Path -Path $SchemaBaseDir -ChildPath 'External Users') -File -Filter '*.sql')) {
    if ($euser.BaseName -notin $ExistingEUsers) {
        $query = Get-Content -LiteralPath $euser.FullName -Raw
        Write-Output "Creating database user $($euser.Name)"
        $null = Invoke-SqlServerQuery -ConnectionString $ConnectionString -CUD -Sql $query
    }
}
}
