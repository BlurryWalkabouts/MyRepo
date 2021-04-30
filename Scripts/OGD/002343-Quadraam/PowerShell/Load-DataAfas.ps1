<#
Datum: 28-09-2017
Auteur: Willem van der Steen (OGD)

Dit script is geschreven in het kader van het BI-project voor Quadraam.

Het roept de API van Afas aan. Hiervoor is een token nodig. Welke dat is wordt bepaald aan de hand van de opgegeven identifier.
Omdat de token alleen ontsleuteld kan worden door de gebruiker die hem versleuteld heeft op hetzelfde apparaat dat hij voor de
versleuteling gebruikt heeft, moet iedere gebruiker op ieder apparaat een apart eigen credential bestand aanmaken. Gebruik hier
Save-StoredCredential.ps1 voor.

Eerst wordt uitgelezen welke tabellen en kolommen beschikbaar zijn. Vervolgens wordt de bijbehorende data opgehaald.

Het dient te worden aangeroepen door een PowerShell job op de SQL instance dmv het commando
PowerShell -File @LocatieVanDitScript\Load-DataAfas.ps1 -Identifier "@Identifier" -Server "@Server" -Database "@Database"
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Param
(
    $Identifier = "test"
    , $Server = "localhost"
    , $Database = "Staging_Quadraam"
)

If ((Get-Variable MyInvocation).Value.MyCommand.CommandType -eq "ExternalScript")
{ $workingDirectory = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path }

Push-Location $workingDirectory

. ./Logging
. ./Get-AfasHeaders
. ./Run-SQLQuery
. ./Load-Metadata
. ./Load-AfasData

Start-Logging

$nl = "`r`n"
$DataSource = "Afas"

$nummer = "48149"
$url = "https://$nummer.afasonlineconnector.nl/profitrestservices/metainfo"
$headers = Get-AfasHeaders -Identifier $Identifier

Try
{
    $result = Invoke-RestMethod -Uri $url -Headers $headers

    # Query om data te verwijderen van connectoren die niet meer worden aangeboden
    $SQLString = "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND Connector NOT IN (''"

    ForEach ($connectorName in $result.getConnectors.id)
    {
        Load-Metadata -DataSource $DataSource -Connector $connectorName -Headers $headers -Server $Server -Database $Database
        $SQLString += ", '$connectorName'"
    }

    $SQLString += ");$nl"

    Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

    Load-AfasData -Connector "DWH_FIN_Administraties" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_BTWcode" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Budget" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Crediteuren" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Dagboeken" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Dimensies" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Dimensies_2" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Dimensies_3" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Grootboek" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Kosten" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Kostendragers" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Kostenplaatsen" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Mutaties" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Periodes" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Projecten" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_FIN_Valuta" -Headers $headers -Server $Server -Database $Database

   #Load-AfasData -Connector "DWH_HR_Berekende_looncomponenten" -Headers $headers -Server $Server -Database $Database -Field "Boekjaar" -Value 2013
    Load-AfasData -Connector "DWH_HR_Dienstverbanden" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Formatieverdeling" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Functie" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Gebrokenfactor" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Loopbaanhistorie" -Headers $headers -Server $Server -Database $Database
   #Load-AfasData -Connector "DWH_HR_Medewerker_journaalpost" -Headers $headers -Server $Server -Database $Database -Field "Jaar" -Value 2013
    Load-AfasData -Connector "DWH_HR_Medewerkers" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Opleidingen" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Opleidingen_bevoegdheden" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Organigram" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Organigram_incl_historie" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Rooster" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Salarissen" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Verlof_parameter" -Headers $headers -Server $Server -Database $Database
    Load-AfasData -Connector "DWH_HR_Werkgeverskosten" -Headers $headers -Server $Server -Database $Database -Field "Jaar" -Value 2014
    Load-AfasData -Connector "DWH_HR_Ziekteverzuim" -Headers $headers -Server $Server -Database $Database
}
Catch
{
    Write-Host $_ -ForegroundColor Red
}

Stop-Logging
Pop-Location