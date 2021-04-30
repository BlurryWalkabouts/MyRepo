<#
Datum: 07-11-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function Get-DUO_Properties
{
    [CmdletBinding()]

    Param
    (
        $SearchField
        , $SearchValues
        , $ReturnField
    )

    $ReturnValues = @()

    ForEach ($connectorName in @(<#"01.-hoofdvestigingen-vo",#>"01.-hoofdvestigingen-basisonderwijs"<#,"02.-hoofdvestigingen-speciaal-(basis)onderwijs"#>))
    {
        ForEach ($SearchValue in $SearchValues)
        {
            $url = "https://api.duo.nl/v0/datasets/$connectorName/search?$SearchField=$SearchValue"
            $result = Invoke-RestMethod -Uri $url

            ForEach ($ReturnValue in $result.results.$ReturnField)
            {
                If ($ReturnValues -notcontains $ReturnValue) {$ReturnValues += $ReturnValue}
            }
        }
    }

    Return $ReturnValues
}