<#
.Synopsis
    This script deployes a database project from within a solution. It contains different options for
    deployment such as the use of a publisch profile (xml). The script (for now) is buildt to support 
    integrated security only.
.DESCRIPTION
    The script is based on the execution of SQLPackage.exe and offers different options to use this
    executable for the deployment of a database project that is part of a vs solution. It allows for 
    the following deployment options:
        - (simple) Deployment of DB without a publish profile.
        - Deployment of DB based using a publish profile.
.EXAMPLE
    Example of how to use this cmdlet
.EXAMPLE
    Another example of how to use this cmdlet
#>
function Deploy-DatabaseFromSolution
{
    [CmdletBinding()]
    Param
    (
        <#SQLPackagePath, the full path of the location of SQLPackge.exe on the server where the agent is running.
        (this is including the exe file)#>
        [Parameter()]
        [string] $SQLPackageExePath,
        #Alias of artifact included for release
        [Parameter()]
        [string] $DBBuildArtifactAlias,
        #DefaultWorkingDirectory
        [Parameter()]
        [string] $DefaultWorkingDir,
        #Path to DACPAC file relative to root of solution (start without \ or / ).
        [string] $DacpacPath,
        #Path to publish profile relative to root of solution (start without \ or / ).
        [Parameter()]
        [string] $PublishProfilePath,
        #Server name for DB deployment. Will be ignored if a publishProfile is provided.
        [Parameter()]
        [string] $ServerName,
        #Database name for DB deployment. Will be ignored if a publishProfile is provided.
        [Parameter()]
        [string] $DatabaseName
    )

    #define default variables
    $DacpacFullPath = "$DefaultWorkingDir\$DBBuildArtifactAlias\drop\$DacpacPath"
    $PublishProfileFullPath = "$DefaultWorkingDir\$DBBuildArtifactAlias\drop\$PublishProfilePath"
    
    #testout for vars
    $SQLPackageExePath
    $PublishProfilePath
    $PublishProfileFullPath
    $DacpacPath
    $DacpacFullPath

    # Run 
    if( $PublishProfilePath -eq "" ){
        Write-Output ( "Processing Deploy with server" )
        & "$SQLPackageExePath" `
        /Action:Publish `
        /SourceFile:/SourceFile:$DacpacFullPath `
        /TargetServerName:$ServerName `
        /TargetDatabaseName:$DatabaseName `
        /p:RegisterDataTierApplication=false `
        /p:IgnoreColumnOrder=True `
        /p:BackupDatabaseBeforeChanges=False `
        /p:IgnoreLoginSids=True `
        /p:IgnorePermissions=True `
        /p:IgnoreRoleMembership=True `
        /p:TreatVerificationErrorsAsWarnings=True `
        /p:CompareUsingTargetCollation=True
    }
    else {
        Write-Output ( "Processing deploy with publish profile")
        & "$SQLPackageExePath" `
        /Action:Publish `
        /SourceFile:$DacpacFullPath `
        /Profile:$PublishProfileFullPath `
        /p:RegisterDataTierApplication=false `
        /p:IgnoreColumnOrder=True `
        /p:BackupDatabaseBeforeChanges=False `
        /p:IgnoreLoginSids=True `
        /p:IgnorePermissions=True `
        /p:IgnoreRoleMembership=True `
        /p:TreatVerificationErrorsAsWarnings=True `
        /p:CompareUsingTargetCollation=True
    }
}