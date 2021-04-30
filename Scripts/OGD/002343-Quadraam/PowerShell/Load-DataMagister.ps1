<#
Datum: 05-12-2017
Auteur: Willem van der Steen (OGD)

Dit script is geschreven in het kader van het BI-project voor Quadraam.

Het dient te worden aangeroepen door een PowerShell job op de SQL instance dmv het commando
PowerShell -File @LocatieVanDitScript\Load-DataMagister.ps1 -Server "@Server" -Database "@Database"
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
. ./Load-MagisterData
. ./Run-SQLQuery

Start-Logging

$nl = "`r`n"
$DataSource = "Magister"

ForEach ($connectorName in @("leerlinggegevens"))
{
    $SQLString = "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND ContentType = 'Data' AND Connector = '$connectorName';$nl"
    Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

    ForEach ($Branch in @("20tz","olympus","sga","mca","geldersmozaiek","symbion"))
    {
        Load-MagisterData -Branch $Branch -Connector $connectorName -Server $Server -Database $Database
    }
}

Stop-Logging
Pop-Location