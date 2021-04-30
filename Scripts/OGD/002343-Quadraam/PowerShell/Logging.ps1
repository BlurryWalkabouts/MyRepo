<#
Datum: 31-01-2018
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function Start-Logging
{
    [CmdletBinding()]

    $destinationFolder = $MyInvocation.PSCommandPath
    $destinationFolder = $destinationFolder.Replace("$($MyInvocation.PSScriptRoot)\","")
    $destinationFolder = "Logs\$($destinationFolder.Replace("".ps1"",""""))"

    If (!(Test-Path -Path $destinationFolder)) { New-Item -Path $destinationFolder -ItemType "directory" }
    # New-Item -Path $destinationFolder -ItemType "directory" -Force | Out-Null

    $destinationFile = "$(Get-Date -Format yyyyMMdd_HHmmss).log"

    Start-Transcript -Path ".\$destinationFolder\$destinationFile"
}

Function Stop-Logging
{
    Stop-Transcript
}