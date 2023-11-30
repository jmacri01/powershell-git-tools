param
(
    [string]$Directory,
    [decimal]$SizeLimitGb,
	[string]$ArchiveDirectory
)

if (!($Directory))
{
    throw "$Directory can not be null"
}

$dirSize = 0

$colItems = @(Get-ChildItem $Directory -Recurse | sort-object -property LastWriteTime | Where-Object { $_.Mode -ne 'd-----' })

foreach ($colItem in $colItems)
{
	$dirSize = $dirSize + $colItem.Length / 1GB
}

#remove old files
$i = 0;
while(($dirSize -gt $SizeLimitGb) -and $colItems[$i])
{
	if($ArchiveDirectory)
	{
		$outputPath = Join-Path -Path $ArchiveDirectory -ChildPath $colItems[$i].Name
		Write-Host "Archiving $($colItems[$i].FullName) to $($outputPath)"		
		ffmpeg -i $colItems[$i].FullName -vcodec libx265 -crf 28 $outputPath -y
	}
	remove-item $colItems[$i].FullName
	$dirSize -= $colItems[$i].Length / 1GB
	$colItems[$i].FullName + " removed!"
	$i++;
}

#cleanup empty directories
$dirs = @(Get-ChildItem $Directory -Recurse | Where-Object { $_.Mode -eq 'd-----' });
foreach($dir in $dirs)
{
	$dirItems = @(Get-ChildItem $dir.FullName -Recurse);
	if($dirItems.Count -eq 0)
	{
		Remove-Item $dir.FullName -Recurse -Force
	}
}