param
(
    [string]$directory,
    [decimal]$sizeLimitGb
)

if (!($directory))
{
    throw "$directory can not be null"
}

while(1)
{
    $dirSize = 0

    $colItems = @(Get-ChildItem $directory -Include $Extension -Recurse | sort-object -property LastWriteTime | Where-Object { $_.Mode -ne 'd-----' })

    foreach ($i in $colItems)
    {
        $dirSize = $dirSize + $i.Length / 1GB
    }

    if(($dirSize -lt $sizeLimitGb) -or !($colItems[0]))
    {
        return
    }

    remove-item $colItems[0].FullName
    $colItems[0].FullName + " removed!"

    $dirItems = @(Get-ChildItem $colItems[0].DirectoryName -Recurse | sort-object -property LastWriteTime | Where-Object { $_.Mode -ne 'd-----' })
    if($dirItems.Count -eq 0)
    {
        Remove-Item $colItems[0].DirectoryName -Recurse -Force
        $colItems[0].DirectoryName + " removed!"
    }
}