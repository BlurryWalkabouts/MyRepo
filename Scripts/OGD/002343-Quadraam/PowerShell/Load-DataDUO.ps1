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
PowerShell -File @LocatieVanDitScript\Load-DataAfas.ps1 -Identifier "@Identifier"
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Param
(
    $BevoegdGezag = "13554"
    , $Server = "localhost"
    , $Database = "Staging_Quadraam"
)

If ((Get-Variable MyInvocation).Value.MyCommand.CommandType -eq "ExternalScript")
{ $workingDirectory = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path }

Push-Location $workingDirectory

. ./Logging
. ./Load-Metadata
. ./Get-DUO_Properties
. ./Load-DUODataMain

Start-Logging

$nl = "`r`n"
$DataSource = "DUO"

#region Haal alle connectoren en hun beschikbare metadata op
$url = "https://api.duo.nl/v0/search"
$result = Invoke-RestMethod -Uri $url

ForEach ($connectorName in $result.results.dataset_name)
{
    Load-Metadata -DataSource $DataSource -Connector $connectorName -Server $Server -Database $Database
}
#endregion

$bgNummers = @()
$brinNummers = @()
$gemNummers = @()
$connectorsDone = @()

#region Vul alle arrays
$bgNummers += $BevoegdGezag

$gemNummers += "0202" # Arnhem
$gemNummers += "0275" # Rheden
$gemNummers += "0274" # Renkum
$gemNummers += "1705" # Lingewaard
$gemNummers += "1734" # Overbetuwe
$gemNummers += "1740" # Neder-Betuwe
$gemNummers += "0268" # Nijmegen
$gemNummers += "0293" # Westervoort
$gemNummers += "0299" # Zevenaar
$gemNummers += "1955" # Montferland
$gemNummers += "0226" # Duiven
$gemNummers += "0196" # Rijnwaarden
$gemNummers += "0222" # Doetinchem

# Haal alle gemeentenummers op waar het bevoegd gezag een hoofdvestiging heeft
$gemNummers = $gemNummers + @(Get-DUO_Properties -SearchField "bevoegd_gezag" -SearchValues $bgNummers -ReturnField "GEMEENTENUMMER") | Select-Object -Unique

# Haal alle bevoegde gezagen op met hoofdvestigingen in die gemeenten
$bgNummers = $bgNummers + @(Get-DUO_Properties -SearchField "gemeentenummer" -SearchValues $gemNummers -ReturnField "BEVOEGD GEZAG NUMMER") | Select-Object -Unique

$bgNummers += "22453"
$bgNummers += "40125"
$bgNummers += "40367"
$bgNummers += "40375"
$bgNummers += "40631"
$bgNummers += "40901"
$bgNummers += "40930"
$bgNummers += "41164"
$bgNummers += "41202"
$bgNummers += "41210"
$bgNummers += "41281"
$bgNummers += "41285"
$bgNummers += "41300"
$bgNummers += "41531"
$bgNummers += "42571"
$bgNummers += "43058"
$bgNummers += "76689"
$bgNummers += "84515"

# Haal alle brin nummers op van hoofdvestigingen in die gemeenten
$brinNummers = $brinNummers + @(Get-DUO_Properties -SearchField "gemeentenummer" -SearchValues $gemNummers -ReturnField "BRIN NUMMER") | Select-Object -Unique

$brinNummers += "00CB"
$brinNummers += "00IH"
$brinNummers += "00KU"
$brinNummers += "00RZ"
$brinNummers += "00TM"
$brinNummers += "00TO"
$brinNummers += "00TQ"
$brinNummers += "00ZR"
$brinNummers += "01FN"
$brinNummers += "01GF"
$brinNummers += "01JE"
$brinNummers += "01JH"
$brinNummers += "01RE"
$brinNummers += "01ST"
$brinNummers += "01VN"
$brinNummers += "02CQ"
$brinNummers += "02FC"
$brinNummers += "02NY"
$brinNummers += "02NZ"
$brinNummers += "02ST"
$brinNummers += "02SY"
$brinNummers += "02VE"
$brinNummers += "03AE"
$brinNummers += "03IJ"
$brinNummers += "03RH"
$brinNummers += "03RM"
$brinNummers += "03RR"
$brinNummers += "04AN"
$brinNummers += "05FF"
$brinNummers += "05LW"
$brinNummers += "07PK"
$brinNummers += "08PS"
$brinNummers += "12NW"
$brinNummers += "12VW"
$brinNummers += "14NQ"
$brinNummers += "14PG"
$brinNummers += "15GW"
$brinNummers += "16QL"
$brinNummers += "16SK"
$brinNummers += "17IM"
$brinNummers += "19PA"
$brinNummers += "19QL"
$brinNummers += "20AD"
$brinNummers += "20CI"
$brinNummers += "20EO"
$brinNummers += "20RM"
$brinNummers += "20TZ"
$brinNummers += "21SK"
$brinNummers += "23GK"
$brinNummers += "24HY"
$brinNummers += "25GL"
$brinNummers += "26JR"
$brinNummers += "26JT"
$brinNummers += "26KH"
$brinNummers += "26NH"
$brinNummers += "30AU"

# Haal alle brin nummers op van hoofdvestigingen behorende bij de bevoegde gezagen
$brinNummers = $brinNummers + @(Get-DUO_Properties -SearchField "bevoegd_gezag" -SearchValues $bgNummers -ReturnField "BRIN NUMMER") | Select-Object -Unique

$brinNummers += "00LJ"
$brinNummers += "00OB"
$brinNummers += "00SO"
$brinNummers += "02MF"
$brinNummers += "02RO"
$brinNummers += "02VN"
$brinNummers += "04FP"
$brinNummers += "05MF"
$brinNummers += "07IC"
$brinNummers += "13EB"
$brinNummers += "14NA"
$brinNummers += "14UM"
$brinNummers += "14XF"
$brinNummers += "16OH"
$brinNummers += "16QF"
$brinNummers += "17AA"
$brinNummers += "17IR"
$brinNummers += "19QS"
$brinNummers += "19SY"
$brinNummers += "19TG"
$brinNummers += "20DH"
$brinNummers += "22ML"
$brinNummers += "22NX"
$brinNummers += "23WK"
$brinNummers += "24DF"
$brinNummers += "26KR"
$brinNummers += "26KY"
$brinNummers += "26MD"
$brinNummers += "26MW"
$brinNummers += "30MM"
#endregion

#region Haal stapsgewijs alle data op
# Haal eerst alle gegevens op van alle bevoegde gezagen uit alle connectoren die een kolom 'bevoegd gezag' hebben
$connectorsDone = $connectorsDone + @(Load-DUODataMain -SearchField "bevoegd_gezag" -SearchValues $bgNummers -connectorsDone $connectorsDone -Server $Server -Database $Database) | Select-Object -Unique

# Haal vervolgens alle gegevens op van alle brin instellingen uit alle connectoren die een kolom 'brin' hebben, exclusief de eerder gebruikte connectoren
$connectorsDone = $connectorsDone + @(Load-DUODataMain -SearchField "brin" -SearchValues $brinNummers -connectorsDone $connectorsDone -Server $Server -Database $Database) | Select-Object -Unique

# Haal vervolgens alle overige (algemene) gegevens op, exclusief de eerder gebruikte connectoren
$connectorsDone = $connectorsDone + @(Load-DUODataMain -SearchField "" -SearchValues @() -connectorsDone $connectorsDone -Server $Server -Database $Database) | Select-Object -Unique
#endregion

Stop-Logging
Pop-Location