function ReWrite-Git-History([string]$gitRepo, [string]$onto, [string[]]$scripts)
{
	#set the new name of the placeholder scripts
	$renameScripts = New-Object "System.Collections.Generic.Dictionary``2[[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089],[System.String, mscorlib, Version=2.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089]]"

	foreach ($script in $scripts)
	{
		$scriptElements = Decompose-ChangeScriptFileName $script
		[int]$newScriptNumber = $newScriptNumber + 1
		[string]$newName = "sql/ChangeScripts/"+$version.Major.ToSTring("00")+"."+$version.Minor.ToSTring("00")+"."+$version.Revision.ToSTring("00")+"."+$newScriptNumber.ToString("0000")+"."+$version.ClientName+"."+"cs"+"."+$scriptElements.Name
		$renameScripts.Add($script, $newName) 
	}
	#$str = $renameScripts | Out-String
	#Write-Host $str 
		
	#get the last commit hash from origin
	$startCommitHash = git log --pretty=%H origin/${onto}..${onto} | select -Last 1

	#Re-Write Git history
	$oldNames = $renameScripts.Keys
	[string]$treeFilterCmd = "'"
	foreach ($oldName in $oldNames)
	{
		$newName = $renameScripts[$oldName] 
		Write-Host
		Write-Host "Rename Change Script: ${oldName} => ${newName}"
		$treeFilterCmd += "if [ -f ""${oldName}"" ]; then mv ""${oldName}"" ""${newName}""; fi; "
	}
	$treeFilterCmd += "'"
	$cmd = "git filter-branch --force --tree-filter ${treeFilterCmd} -- ${startCommitHash}^..HEAD"
	
	#Clean-up lingering jobs
	Get-Job | Stop-Job
	Get-Job | Remove-Job
	
	#Start a new background job for Git ReWrite
	$job = Start-Job -ArgumentList:@($cmd, $gitRepo) -ScriptBlock {
	param ([string]$cmd, [string]$gitRepo) 
	cd $gitRepo
	Invoke-Expression $cmd
	}
	
	#while job is running show a progress bar
	$p = 1 
	While ($Job.State -eq "Running")
	{
		if ($p -gt 100) {$p = 1}
		Write-Progress  -Activity "Re-writing Git History" -PercentComplete $p
		Start-Sleep -Seconds 1
		$p += 1
	}
	
	$outPut = Receive-Job -Job $job
	Write-Host
	Write-Host $outPut -ForegroundColor DarkGray
	
	#return new script names if needs to be rerun
	return $renameScripts.Values
}



function Confirm-Version($left, $right)
{
    if($left.Major -ne $right.Major -or
        $left.Minor -ne $right.Minor -or
        $left.Revision -ne $right.Revision -or
        $left.ScriptNumber -ne $right.ScriptNumber -or
        $left.ClientName -ne $right.ClientName)
    {
        return $false
    }
    return $true
}

