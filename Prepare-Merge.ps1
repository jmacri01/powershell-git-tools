param
(
    [parameter(Mandatory=$true)]
	[string]$childBranchName,
    
	[string]$masterBranchName = 'master'
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. $scriptDir\lib\lib-GitUtils.ps1

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