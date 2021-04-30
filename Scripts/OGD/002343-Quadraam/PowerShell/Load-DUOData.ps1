<#
Datum: 07-11-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function Load-DUOData
{
    [CmdletBinding()]

    Param
    (
        $Connector
        , $Field = ""
        , $Value = ""
        , $Server
        , $Database
    )

    $nl = "`r`n"
    $DataSource = "DUO"

    $sw = [Diagnostics.Stopwatch]::StartNew()
    $url = "https://api.duo.nl/v0/datasets/$Connector" + (&{ If($Field -ne "") {"/search?$Field=$Value"} })
    # $result = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    $result = (New-Object System.Net.WebClient -Property @{ Encoding = [System.Text.Encoding]::UTF8 }).DownloadString($url)
    $sw.Stop()

    #Write-Host "$url ~ $($result.Length) ~ $([Math]::Round(($sw.Elapsed.TotalSeconds),2))s"
    #Write-Host "API ~ $([Math]::Round(($sw.Elapsed.TotalSeconds),2))s ~ $([Math]::Round(([System.GC]::GetTotalMemory("ForceFullCollection")/1MB),2)) MB"

    If (($result | ConvertFrom-Json).results.Count -gt 0)
    {
        $SQLString = ""`
            + "INSERT INTO setup.DataObjects (DataSource, ContentType, Connector, BulkColumn, ImportDuration)$nl"`
            + "SELECT '$DataSource', 'Data', '$Connector', N'$($result.Replace("'","''"))', $($sw.ElapsedMilliseconds);$nl"

        Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString
    }
}