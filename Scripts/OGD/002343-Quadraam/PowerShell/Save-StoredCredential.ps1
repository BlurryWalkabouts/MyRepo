<#
Datum: 13-12-2017
Auteur: Willem van der Steen (OGD)

Dit script is geschreven in het kader van het BI-project voor Quadraam.

Het slaat een opgegeven token (Afas) of gebruikersnaam-wachtwoord-combinatie (Magister) versleuteld op in een credential bestand.
De credentials zijn alleen te ontsleutelen door dezelfde gebruiker op hetzelfde apparaat. Dit script moet daarom worden uitgevoerd
door de gebruiker (of proxy) die de API gaat aanroepen op het apparaat waarvandaan de API wordt aangeroepen.
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

If ((Get-Variable MyInvocation).Value.MyCommand.CommandType -eq "ExternalScript")
{ $workingDirectory = Split-Path (Get-Variable MyInvocation).Value.MyCommand.Path }

Push-Location $workingDirectory

#region Sla de token op in een credential bestand op basis van de opgegeven identifier en ingelogde gebruiker
# Importeer de functies die zorgen voor het beheren van wachtwoorden (cq tokens)
# https://code.ogdsoftware.nl/beheer-outsourcing/CustomFunctions
# Help> Get-Command -Noun *StoredCredential* -Module CustomFunctions | ForEach {Get-Help $_.Name -ShowWindow}
Import-Module -FullyQualifiedName .\CustomFunctions\CustomFunctions.psd1 -Force

# Vraag de gebruiker om input
Clear-Host

Switch (Read-Host -Prompt "Geef de data bron op ~ [A]fas [M]agister [S]harePoint")
{
    A { $DataSource = "Afas"; Break }
    M { $DataSource = "Magister"; Break }
    S { $DataSource = "SharePoint"; Break }
    default { $DataSource = ""; Break }
}

If ($DataSource -eq "Afas")
{
    $Identifier = Read-Host -Prompt "Geef een unieke identifier mee"
}
ElseIf ($DataSource -eq "Magister")
{
    $Identifier = Read-Host -Prompt "Om welke hoofdvestiging gaat het?"
}
ElseIf ($DataSource -eq "SharePoint")
{
    $Identifier = "live"
}
Else
{
    Write-Host "Geen geldige bron gekozen"
    Break
}

$notes = Read-Host -Prompt "Ruimte voor opmerkingen"

If ($notes -eq "") { $notes = "$DataSource ~ $Identifier" } Else { $notes = "$DataSource ~ $Identifier ~ $notes" }

# Bepaal de loginnaam van de huidige gebruiker, zonder domein
$currentUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -Split "\\")[1]

# Bepaal de lokatie en bestandsnaam van het credential bestand
$tokenFilePath = ".\Credentials"
$tokenFileName = "token_$($DataSource)_$($Identifier)_$($currentUser)".ToLower()

If ($DataSource -eq "Afas") { $userName = $tokenFileName } Else { $userName = "" }

# Sla de token op in een credential bestand
# If (!(Test-Path -Path $tokenFilePath)) { New-Item -Path $tokenFilePath -ItemType "directory" }
New-Item -Path $tokenFilePath -ItemType "directory" -Force | Out-Null
Save-StoredCredential -Path $tokenFilePath -FileName $tokenFileName -Credential $userName -Notes $notes
#endregion

# Geef alle huidige beschikbare credential bestanden weer
Show-StoredCredential -Path $tokenFilePath

Pop-Location