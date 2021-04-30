<#
Datum: 29-11-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

. ./Get-Credentials
. ./Run-SQLQuery

Function Load-MagisterData
{
    [CmdletBinding()]

    Param
    (
        $Branch
        , $Connector
        , $Server
        , $Database
    )

    $nl = "`r`n"
    $DataSource = "Magister"

    $Credentials = Get-Credentials -DataSource $DataSource -Identifier $Branch
    $SessionToken = $Credentials.GetNetworkCredential().UserName + "%3B" + $Credentials.GetNetworkCredential().Password

    $url = "https://$Branch.swp.nl:8800/doc?Function=GetData&Library=Data&SessionToken=$SessionToken&Layout=$Connector&Type=XMLTable"
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
            # $result = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
            $result = (New-Object System.Net.WebClient -Property @{ Encoding = [System.Text.Encoding]::UTF8 }).DownloadString($url)
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
        #If ([$aantal rijen] -gt 0)
        #{
            $SQLString = ""`
                + "INSERT INTO setup.DataObjects (DataSource, ContentType, Connector, XMLData, ImportDuration)$nl"`
                + "SELECT '$DataSource', 'Data', '$Connector', N'$($result.Replace("'","''").Replace("utf-8","utf-16"))', $($sw.ElapsedMilliseconds);$nl"

            Run-SQLQuery -Server $Server -Database $Database -CommandText $SQLString
        #}
    }
    #endregion
}