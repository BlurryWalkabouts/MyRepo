function Get-StoredCredential {
    <#
    .synopsis
        retrieves a credential file en decrypts the password and returns a pscredential object.
    .example
        $domainadmins = show-storedcredential |where-object{$_.username -eq 'administrator'} |get-Storedcredential
    .example
        $cred = get-StoredCredential -Filename domainadministrator
    .parameter FullName
        FullName Path to the credential file. Either specify FullName or FileName and Path.
    .parameter FileName
        FileName of the credential file. Specify together with Path.
    .parameter Path
        Path to the credential file. Specify together with FileName.
    #>
    [CmdletBinding(DefaultParameterSetName='FileFullName')]
    [OutputType([System.Management.Automation.PSCredential])]
    param(
        [parameter(Mandatory=$false, position=0,ParameterSetName='FileFullName', ValueFromPipelineByPropertyName=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$FullName,
        [Parameter(Mandatory=$false, position=0,ParameterSetName='DirectoryPathFileName', ValueFromPipelineByPropertyName=$true)]
        [string]$Path, 
        [Parameter(Mandatory=$false, position=1,ParameterSetName='DirectoryPathFileName' , ValueFromPipelineByPropertyName=$true)]
        [string]$FileName
    )

    $DefaultPaths = @('c:\_automation\credentials',"$($Env:USERPROFILE)")
    If ($Path -match '\.cred$' -and $Path -match '\\\\|[a-zA-Z]:\\|testdrive:\\') {
        Write-Verbose "You passed a File (Full)Name with extension .cred for parameter -Path; assuming you meant to use: `n`t $($MyInvocation.InvocationName) -FullName $Path"
        $FullName = $Path
    }
    ElseIf (-Not $FullName) {
        If ($FileName -notmatch '\.\w{1,4}$') { # https://regex101.com/r/GWdF3T/1
            Write-Verbose "adding extension .cred for all extension-less filenames; so $FileName becomes $($FileName).cred"
            $FileName = "$($FileName).cred" # adding extension .cred for all extension-less filenames
        }
        If (-Not $Path) {
            If (Test-Path -Path ($DefaultPaths | Select-Object -First 1) -ErrorAction SilentlyContinue ) {
                Write-Verbose "Defaulting to -Path $($DefaultPaths | Select-Object -First 1)"
                $Path = $DefaultPaths | Select-Object -First 1
            }
            Else {
                Write-Verbose "Defaulting to -Path $($DefaultPaths | Select-Object -Last 1)"
                $Path = $DefaultPaths | Select-Object -Last 1
            }
        
        } 
        $FullName = Join-Path -Path $Path -ChildPath $FileName
    }
    
    Try{
        If ( (Test-Path $FullName -ErrorAction Stop) -eq $false) {
            Write-Error "file $FullName not found"
        }
        Else {
            If (Get-Command -Name Show-StoredCredential) {
                Write-Verbose "$(Show-StoredCredential -Path (Split-Path $FullName) | Where-Object {$_.FullName -eq $FullName} | Select-Object FullName,UserName,"encrypted*",Notes,information | Out-String)"
            }
            $credentialobject = Get-Content $FullName -Raw | ConvertFrom-Json
            $username = $credentialobject.username
            $password = $credentialobject.password | ConvertTo-SecureString -ErrorAction Stop
            New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $UserName,$password
        }
        #Else {
        #    Write-Error "file $FullName not found"
        #}
    }

    Catch [Security.Cryptography.CryptographicException] {
        # i am not totally sure if this ( catch [System.SystemException] ) is a specific enough catch block for this specific error but it works. FrodoB: no, it isn't. I am now fixing the code for throwing this error on a "Test-Path : Cannot bind argument to parameter 'Path' because it is an empty string." error ...
        # MAKE SURE that if you change the error message below, you also change the redirected Error-Stream Output text in the Pester Test ($Error = ... 2>&1  )
        Write-Error "this credential file ( $(Split-Path $FullName -Leaf) ) cannot be decrypted, it can be only be opened by the user who wrote it, and on the system where it was written ( $($credentialobject.'encrypted on ComputerName') ). `n$($_ | Out-String)"
    }
    Catch {
        If ($_.Exception.Message -like "*Test-Path : Cannot bind argument to parameter 'Path' because it is an empty string*") {
            Write-Error "Make sure to pass a FILE FullName for parameter -FullName OR a DIRECTORY Name for -Path in combination with a FILE Name for -FileName (a .cred file extension is assumed, so you can use BaseName) `n$($_ | Out-String)"       
        }
        Else {
            Write-Error $_
        }
    }


}