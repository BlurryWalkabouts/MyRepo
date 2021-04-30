<#
Datum: 19-01-2018
Auteur: Willem van der Steen (OGD)

Dit script is geschreven in het kader van het BI-project voor Quadraam.

Het dient te worden aangeroepen door een PowerShell job op de SQL instance dmv het commando
PowerShell -File @LocatieVanDitScript\Load-DataSharePoint.ps1 -Server "@Server" -Database "@Database"
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Param
(
    $Server = "localhost"
    , $Database = "Staging_Quadraam"
)

If ((Get-Variable MyInvocation).Value.MyCommand.CommandType -eq "ExternalScript")
{ $workingDirectory = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path }

Push-Location $workingDirectory

. ./Logging
. ./DownloadFromSharepoint
. ./Run-SQLQuery

Start-Logging

$nl = "`r`n"
$DataSource = "SharePoint"

$SiteCollectionName = "quadraam"
$SiteName = "/teams/projecten/dwh_beheer"
$Identifier = "live"

ForEach ($connectorName in @("Forecast"))
{
    # Download files from SharePoint
    $ListTitle = $connectorName
    $LocalDestinationFolder = "F:\$ListTitle"
    DownloadFromSharePoint -SiteCollectionName $SiteCollectionName -SiteName $SiteName -ListTitle $ListTitle -LocalDestinationFolder $LocalDestinationFolder -Identifier $Identifier

    $SQLString = "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND ContentType = 'Data' AND Connector = '$connectorName';$nl"
    Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

    ForEach ($file in Get-ChildItem -Path $LocalDestinationFolder -File)
    {
        # Load file contents
        $sw = [Diagnostics.Stopwatch]::StartNew()
        $result = Get-Content "$LocalDestinationFolder\$file"
        $sw.Stop()

        # Insert file contents into database
        $SQLString = ""`
            + "INSERT INTO setup.DataObjects (DataSource, ContentType, Connector, XMLData, ImportDuration)$nl"`
            + "SELECT '$DataSource', 'Data', '$connectorName', N'$result', $($sw.ElapsedMilliseconds);$nl"

        Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

        Write-Host "$(Get-Date -Format FileDateTime) > File contents $file inserted into $Server.$Database.setup.DataObjects" -ForegroundColor Green

        # Move processed file to Completed folder
        $LocalDestinationFolderCompleted = "$LocalDestinationFolder\Completed"
        If (!(Test-Path -Path $LocalDestinationFolderCompleted)) { New-Item -Path $LocalDestinationFolderCompleted -ItemType "directory" }

        Move-Item -Path "$LocalDestinationFolder\$file" -Destination "$LocalDestinationFolderCompleted\$(Get-Date -Format yyyyMMdd_HHmmss)_$file"

        Write-Host "$(Get-Date -Format FileDateTime) > File $file moved to $LocalDestinationFolderCompleted\$(Get-Date -Format yyyyMMdd_HHmmss)_$file" -ForegroundColor Green
    }
}

Stop-Logging
Pop-Location