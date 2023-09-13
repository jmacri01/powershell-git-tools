param
(
    [string]$directory
)

if (!($directory))
{
    throw "$directory can not be null"
}

$colItems = @(Get-ChildItem $directory -Include $Extension -Recurse | sort-object -property LastWriteTime | Where-Object { $_.Mode -ne 'd-----' })

foreach($colItem in $colItems)
{
    if(-not ($colItem.Name -match "_\d\d\d\d\-\d\d\-\d\d_"))
    {
        continue
    }

    $date = ($colItem.Name -replace ".*(?=\d\d\d\d\-\d\d\-\d\d)", "") -replace "(?<=\d\d\d\d\-\d\d\-\d\d).*", ""
    if($date -match "\d\d\d\d\-\d\d\-\d\d")
    {
        $fileName = $colItem.Name

        if(-not (Test-Path "$directory\$date"))
        {
            mkdir "$directory\$date"
        }

        Move-Item -Path $colItem.FullName -Destination "$directory\$date\$fileName"
        Write-Host "Moving $fileName to $directory\$date\$fileName"
    }
}