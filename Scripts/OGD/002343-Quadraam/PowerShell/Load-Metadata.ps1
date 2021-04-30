<#
Datum: 20-10-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Run-SQLQuery

Function Load-Metadata
{
    [CmdletBinding()]

    Param
    (
        $DataSource
        , $Connector
        , $Headers
        , $Server
        , $Database
    )

    $nl = "`r`n"

    Try
    {
        $sw = [Diagnostics.Stopwatch]::StartNew()
        If ($DataSource -eq "Afas")
        {
            $nummer = "48149"
            $url = "https://$nummer.afasonlineconnector.nl/profitrestservices/metainfo/get/$Connector"
            $result = Invoke-WebRequest -Uri $url -Headers $Headers -UseBasicParsing
        }
        ElseIf ($DataSource -eq "DUO")
        {
            $url = "https://api.duo.nl/v0/datasets/$Connector/search?brin=0000"
            $result = Invoke-WebRequest -Uri $url -UseBasicParsing
        }
        $resultCode = $result.StatusCode
        $sw.Stop()
    }
    Catch
    {
        $resultCode = ""
    }

    If ($resultCode -eq 200)
    {
        $SQLString = ""`
            + "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND ContentType = 'Metadata' AND Connector = '$Connector';$nl"`
            + "INSERT INTO setup.DataObjects (DataSource, ContentType, Connector, BulkColumn, ImportDuration)$nl"`
            + "SELECT '$DataSource', 'Metadata', '$Connector', N'$($result.Content.Replace("'","''"))', $($sw.ElapsedMilliseconds);$nl"

        Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString
    }
}