<#
Datum: 22-11-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Run-SQLQuery
. ./Load-DUOData

Function Load-DUODataMain
{
    [CmdletBinding()]

    Param
    (
        $SearchField
        , $SearchValues
        , $connectorsDone
        , $Server
        , $Database
    )

    $nl = "`r`n"
    $DataSource = "DUO"

    # Haal alle connectoren op die een veld '$SearchField' hebben
    $url = "https://api.duo.nl/v0/search" + (&{ If($SearchField -ne "") {"?field_name=$SearchField"} })
    $result = Invoke-RestMethod -Uri $url

    # Haal de gegevens op van iedere connector die een veld '$SearchField' heeft en markeer deze als Done
    ForEach ($connectorName in $result.results.dataset_name)
    {
        If ($connectorsDone -notcontains $connectorName)
        {
            $SQLString = "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND ContentType = 'Data' AND Connector = '$connectorName';$nl"
            Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

            If ($SearchField -ne "")
            {
                ForEach ($SearchValue in $SearchValues)
                {
                    Load-DUOData -Connector $connectorName -Field $SearchField -Value $SearchValue -Server $Server -Database $Database
                }
            }
            Else
            {
                Load-DUOData -Connector $connectorName -Server $Server -Database $Database
            }

            $connectorsDone += $connectorName
        }
    }

    Return $connectorsDone
}