param
(
    [string]$directory,
    [decimal]$sizeLimitGb
)

if (!($directory))
{
    throw "$directory can not be null"
}

$dirSize = 0

$colItems = @(Get-ChildItem $directory -Recurse | sort-object -property LastWriteTime | Where-Object { $_.Mode -ne 'd-----' })

foreach ($colItem in $colItems)
{
	$dirSize = $dirSize + $colItem.Length / 1GB
}

#remove old files
$i = 0;
while(($dirSize -gt $sizeLimitGb) -and $colItems[$i])
{
	remove-item $colItems[$i].FullName
	$dirSize -= $colItems[$i].Length / 1GB
	$colItems[$i].FullName + " removed!"
	$i++;
}

#cleanup empty directories
$dirs = @(Get-ChildItem $directory -Recurse | Where-Object { $_.Mode -eq 'd-----' });
foreach($dir in $dirs)
{
	$dirItems = @(Get-ChildItem $dir -Recurse);
	if($dirItems.Count -gt 0)
	{
		Remove-Item $dir -Recurse -Force
	}
}