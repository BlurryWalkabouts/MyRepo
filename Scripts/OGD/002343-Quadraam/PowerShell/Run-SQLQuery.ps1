<#
Datum: 19-10-2017
Auteur: Willem van der Steen (OGD)
#>

# Toggle alle 'regio's' in één keer
# $psISE.CurrentFile.Editor.ToggleOutliningExpansion()

Function Run-SQLQuery
{
    Param
    (
        $Server
        , $Database
        , $CommandText
        , $Debug = 0
    )

    $nl = "`r`n"

    $CommandText = "BEGIN TRANSACTION;$nl"`
        `
        + "BEGIN TRY$nl"`
        + $CommandText`
        + "END TRY$nl"`
        `
        + "BEGIN CATCH$nl"`
        + "IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;$nl"`
        + "END CATCH;$nl"`
        `
        + "IF @@TRANCOUNT > 0 COMMIT TRANSACTION;$nl"

    If ($Debug -eq 0)
    {
        $DBConn = New-Object System.Data.SqlClient.SqlConnection
        $DBConn.ConnectionString = "SERVER=$Server;DATABASE=$Database;Integrated Security=True"

        $DBCmd = New-Object System.Data.SqlClient.SqlCommand
        $DBCmd.Connection = $DBConn

        $DBCmd.CommandText = $CommandText
        $DBCmd.CommandTimeout = 0

        $DBConn.Open()
        $affectedRows = $DBCmd.ExecuteNonQuery()
        $DBConn.Close()
        $DBCmd.Dispose()
        $DBConn.Dispose()
    }
    ElseIf ($Debug -eq 1)
    {
        Write-Host $CommandText
    }

#    Return $affectedRows
}