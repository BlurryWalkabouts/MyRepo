<#
Datum: 20-10-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Run-SQLQuery

Function Load-AfasData
{
    [CmdletBinding()]

    Param
    (
        $Connector
        , $Field = ""
        , $Value = ""
        , $Skip = 0
        , $Take = 60000
        , $Headers
        , $Server
        , $Database
    )

    $nl = "`r`n"
    $DataSource = "Afas"

    $SQLString = "DELETE FROM setup.DataObjects WHERE DataSource = '$DataSource' AND ContentType = 'Data' AND Connector = '$Connector';$nl"
    Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString

    While (1 -eq 1)
    {
        # Haal alle records uit $Connector op in batches van $Take

        $nummer = "48149"
        $url = "https://$nummer.afasonlineconnector.nl/profitrestservices/connectors/$Connector" + (&{ If($Field -ne "") {"/$Field/$Value"} }) + "?skip=$Skip&take=$Take"
        Write-Host $url

        #region Probeer de batch drie keer te downloaden. Als het in drie keer niet lukt, is het helaas pech hebben...
        
        # https://blogs.technet.microsoft.com/lukeb/2017/06/06/powershell-trycatchretry/
        # https://blogs.endjin.com/2014/07/how-to-retry-commands-in-powershell/

        $tries = 0
        $maxtries = 3

        While ($tries -lt $maxtries)
        {
            Try
            {
                $ErrorActionPreference = "Stop"
                $tries++

                $sw = [Diagnostics.Stopwatch]::StartNew()
                # https://briancaos.wordpress.com/2012/06/15/an-existing-connection-was-forcibly-closed-by-the-remote-host/
                # $result = (Invoke-WebRequest -Uri $url -Headers $headers -DisableKeepAlive -UseBasicParsing).Content

                # https://blog.jourdant.me/post/3-ways-to-download-files-with-powershell
                $wc = New-Object System.Net.WebClient -Property @{ Encoding = [System.Text.Encoding]::UTF8 }
                # $wc.Headers = $headers
                $wc.Headers.Add($($headers.Keys[0]), $($headers.Values[0]))
                $result = $wc.DownloadString($url)
                $sw.Stop()

                Write-Host "Try $($tries): $(Get-Date -Format FileDateTime) > Success"
                $tries = 99
            }
            Catch
            {
                Write-Host "Try $($tries): $(Get-Date -Format FileDateTime) > $($Error[0])"
                Start-Sleep -Seconds 10
                $ErrorActionPreference = "SilentlyContinue"
            }
        }

        #Write-Host "$url ~ $($result.Length) ~ $([Math]::Round(($sw.Elapsed.TotalSeconds),2))s"
        #Write-Host "API ~ $([Math]::Round(($sw.Elapsed.TotalSeconds),2))s ~ $([Math]::Round(([System.GC]::GetTotalMemory("ForceFullCollection")/1MB),2)) MB"

        #endregion

        #region Schrijf de dataset (batch) weg naar de tabel setup.DataObjects in de database

        # Check na het downloaden eerst of er überhaupt een poging geslaagd is (en de dataset dus niet leeg is)
        If ($tries -eq 99)
        {
            # Check of de dataset behalve metadata ook inhoud bevat
            If (($result | ConvertFrom-Json).rows.Count -gt 0)
            {
                $SQLString = ""`
                    + "INSERT INTO setup.DataObjects (DataSource, ContentType, Connector, BulkColumn, ImportDuration)$nl"`
                    + "SELECT '$DataSource', 'Data', '$Connector', N'$($result.Replace("'","''"))', $($sw.ElapsedMilliseconds);$nl"

                Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString
            }
            # De laatste iteratie levert by design een lege dataset op, zodat je weet je dat je alles gehad hebt
            Else
            {
                # Als de connector op een veld wordt gefilterd en de lege dataset is niet de eerste iteratie, verhoog dan de waarde van het filter met 1
                If ($Field -ne "" -and $Skip -gt 0)
                {
                    $Skip = 0 - $Take
                    $Value += 1
                }
                # Breek anders de while-loop af
                Else
                {
                    Break
                }
            }
        }

        #endregion

        # Ga naar de volgende batch
        $Skip += $Take
    }
}