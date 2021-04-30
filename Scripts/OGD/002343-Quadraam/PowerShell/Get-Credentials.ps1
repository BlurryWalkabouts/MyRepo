<#
Datum: 10-01-2018
Auteur: Willem van der Steen (OGD)

Haal op basis van de opgegeven identifier en ingelogde gebruiker de credentials voor de verbinding met de databron op
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function Get-Credentials
{
    Param
    (
        $DataSource
        , $Identifier
    )

    # Importeer de functies die zorgen voor het beheren van wachtwoorden (cq tokens)
    # https://code.ogdsoftware.nl/beheer-outsourcing/CustomFunctions
    # Help> Get-Command -Noun *StoredCredential* -Module CustomFunctions | ForEach {Get-Help $_.Name -ShowWindow}
    Import-Module -FullyQualifiedName .\CustomFunctions\CustomFunctions.psd1 -Force

    # Bepaal de loginnaam van de huidige gebruiker, zonder domein
    $currentUser = ([System.Security.Principal.WindowsIdentity]::GetCurrent().Name -Split "\\")[1]

    # Bepaal de lokatie en bestandsnaam van het bestand met de versleutelde token
    $tokenFilePath = ".\Credentials"
    $tokenFileName = "token_$($DataSource)_$($Identifier)_$($currentUser)".ToLower()

    # Haal de credential op en zet deze weer om naar de token
    $credentials = Get-StoredCredential -Path $tokenFilePath -FileName $tokenFileName

    Return $credentials
}