param
(
	[Parameter(Mandatory = $true)]
    [string]$searchTerm
)

$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
. $scriptDir\lib\lib-GitUtils.ps1

$branchToCheckout = Find-GitBranch $searchTerm

$localBranchName = ($branchToCheckout -replace "origin\/", "")

if((git branch | findstr /c:"${localBranchName}").Length -gt 0)
{
    git checkout $localBranchName 
    return
}

git checkout -b $localBranchName $branchToCheckout
Write-Host ""