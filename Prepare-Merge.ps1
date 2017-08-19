param
(
    [parameter(Mandatory=$true)]
	[string]$childBranchName,
    
	[string]$masterBranchName = 'sprint',

	[string]$repoLocation = "c:\core\app\git\ims\"
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. $scriptDir\lib\lib-GitUtils.ps1
. $scriptDir\lib\lib-DotnetUtils.ps1

$repoLocation = $repoLocation.TrimEnd('\')

$gitStatus = git status -s

if($gitStatus -ne $null -or $gitStatus.Length -gt 0)
{
    Write-Host "Your staging must be empty"
    return
}

git checkout $masterBranchName

git pull --progress "origin"

$resolvedChildBranchName = Find-GitBranch $childBranchName

git merge --no-ff --no-commit $resolvedChildBranchName

$pwd = pwd

$assemblyVersion = Get-GlobalAssemblyVersion "${repoLocation}\dotnet\GlobalAssemblyInfo.cs"

$scriptsLocation = "${repoLocation}\devops\powershell"
cd $scriptsLocation
 
.\Rebase-PlaceholderScripts -s r -newVersion $assemblyVersion

cd $pwd