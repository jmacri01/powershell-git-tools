function Find-GitBranch([string]$searchTerm)
{
    Write-Host "performing git fetch"
    git fetch --all > $null

    $branchesFound = git branch -r | findstr /c:"${searchTerm}" | foreach{$_.Trim()}

    if(-not ($branchesFound -is [system.array]))
    {
        $branchesFound = @($branchesFound)
    }

    if($branchesFound -eq $null -or $branchesFound.Length -eq 0 -or ($branchesFound.Length -eq 1 -and $branchesFound[0] -eq $null))
    {
        Write-Host "No branches found!"
        Write-Host ""
        return
    }

    Write-Host ""

    if($branchesFound.Length -gt 1)
    {
        $i = 0
        foreach($branch in $branchesFound)
        {
            $i += 1
            Write-Host $i -noNewLine -foregroundcolor "Yellow"
            Write-Host ". " -noNewLine -foregroundcolor "Yellow"
            Write-Host $branch -foregroundcolor "Yellow"
        }

        Write-Host ""
        $branchNum = Read-Host -Prompt 'Which branch do you want?'
        while((-not ($branchNum -match "^\d+$")) -or ([convert]::ToInt32($branchNum, 10) -gt $branchesFound.Length) -or ([convert]::ToInt32($branchNum, 10) -lt 1))
        {
            $branchNum = Read-Host -Prompt 'Enter the number corresponding to the branch'
        }
        Write-Host ""

        $branchToPrint = $branchesFound[($branchNum - 1)]
    }
    else
    {
        $branchToPrint = $branchesFound[0]
    }

    return $branchToPrint
}