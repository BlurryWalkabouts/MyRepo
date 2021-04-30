


# Copy build outputs and deployment options to deployment directory
$deploymentDir = ".\deployment"
New-Item -Type Directory -Force $deploymentDir
Copy-Item -LiteralPath "bin\$environment\*.*" -Destination $deploymentDir -Force
#Copy-Item -LiteralPath .\deploymentoptions\*.* -Destination $deploymentDir -Force

# Update deployment targets and options with parameters
for ($extension -in @('deploymenttargets', 'deploymentoptions')) {
	$template = Get-Content "General.${$extension}"
	$expandedTemplate = $ExecutionContext.InvokeCommand.ExpandString($template)
	$expandedTemplate | Set-Content "$deploymentDir\General.${$extension}"
}