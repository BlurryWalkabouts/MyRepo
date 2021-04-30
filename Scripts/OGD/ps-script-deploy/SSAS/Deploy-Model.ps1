param(
	[Parameter(Mandatory)]
	[string]$AdoDeployClientId,
	[Parameter(Mandatory)]
	[string]$AdoDeployAgentAuthorizationKey,
	[Parameter(Mandatory)]
	[string]$DataSourceUser,
	[Parameter(Mandatory)]
	[string]$DataSourcePassword,
	[Parameter(Mandatory)]
	[string]$WorkingDirectory,
	[Parameter(Mandatory)]
	[string]$AnalysisCubeArtifactPath,
	[Parameter(Mandatory)]
	[string]$DeploymentServerDatabase,
	[Parameter()]
	[string]$AnalysisServerInstance,
	[Parameter()]
	[string]$AnalysisServicesServer = "asazure://westeurope.asazure.windows.net/$($AnalysisServerInstance)"
)

Import-Module -Name SqlServer
$ErrorActionPreference = "Stop"

# Update deployment targets and options with parameters
foreach ($extension in @('deploymenttargets', 'deploymentoptions')) {
	$template = Get-Content "$($WorkingDirectory)\templates\General.$($extension)"
	$expandedTemplate = $ExecutionContext.InvokeCommand.ExpandString($template)
	$expandedTemplate | Set-Content "$($AnalysisCubeArtifactPath)\Model.$($extension)"
}

# Create the deployment script
Microsoft.AnalysisServices.Deployment.exe "$($AnalysisCubeArtifactPath)\Model.asdatabase" /s /o:"$($AnalysisCubeArtifactPath)\deploy.xmla" /d

# Updating xmla with proper credentials
$xmladata = Get-Content -Path "$($AnalysisCubeArtifactPath)\deploy.xmla" -raw | ConvertFrom-Json

foreach ($ds in $xmladata.sequence.operations.createOrReplace.database.model.datasources){
	<#
	"credential": {
        "AuthenticationKind": "OAuth2",
        "kind": "SQL",
        "path": "ogdw.database.windows.net;LIFT_DW",
        "Expires": "Fri, 30 Nov 2018 18:53:58 GMT",
        "RefreshToken": "********"
	  }
		$ds.Credential.AuthenticationKind = 'SQL'
		$ds.Credential.Username = $AnalysisServerUserName

		#Add password property to the object.
		$ds.credential | Add-Member -NotePropertyName Password -NotePropertyValue $AnalysisServerPassword
	#>

	$dsCred = @{
        AuthenticationKind = "UsernamePassword"
        Username = "$($DataSourceUser)"
		Password = "$($DataSourcePassword)"
        EncryptConnection = $true
	}
	
    $ds.Credential = $dsCred
}

$xmladata | ConvertTo-Json -depth 100 | Out-File "$($AnalysisCubeArtifactPath)\deploy.xmla"
#endregion

# Generating Credential
$password = ConvertTo-SecureString $AdoDeployAgentAuthorizationKey -AsPlainText -Force
$credential = New-Object System.Management.Automation.PSCredential ($AdoDeployClientId, $password)

# Deploy the model
Invoke-ASCmd –InputFile "$($AnalysisCubeArtifactPath)\deploy.xmla" -Server $AnalysisServicesServer -Credential $credential