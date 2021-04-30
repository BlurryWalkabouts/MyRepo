<#
Datum: 19-10-2017
Auteur: Willem van der Steen (OGD)

Stel de headers voor de verbinding met de Afas API samen op basis van de opgegeven identifier
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Get-Credentials

Function Get-AfasHeaders
{
    Param
    (
        $Identifier
    )

    $DataSource = "Afas"

    $credentials = Get-Credentials -DataSource $DataSource -Identifier $Identifier
    $token = $credentials.GetNetworkCredential().Password

    # In de aanroep moet de token geconverteerd worden naar een base64-string
    # https://static-kb.afas.nl/datafiles/help/2_9_7/SE/NL/index.htm#App_Cnr_Rest_Call.htm
    $encodedToken = [System.Convert]::ToBase64String([System.Text.Encoding]::ASCII.GetBytes($token))
    $authValue = "AfasToken $encodedToken"
    $headers = @{Authorization = $authValue}
    # $headers = New-Object System.Net.WebHeaderCollection
    # $headers.Add("Authorization",$authValue)

    Return $headers
}