param
(
    [Parameter(Mandatory=$true)]
    [String[]] $SplitTimes,
    [Parameter(Mandatory=$true)]
    [String] $InputFile,
    [Parameter(Mandatory=$true)]
    [String] $OutputFolder,
    [Parameter(Mandatory=$true)]
    [String] $OutputFileName,
    [Parameter(Mandatory=$true)]
    [String] $OutputFileExt,
    [int] $FileNoStart = 1,
    [String]$StartTime = '00:00:00'
)

foreach($time in $SplitTimes)
{
    Write-Host "Start time:: $($StartTime)"
    Write-Host "End time:: $($time)"
    Write-Host "File No: $($fileNoStart)"

    ffmpeg -i $InputFile -vcodec copy -acodec copy -ss $StartTime -to $time "$($OutputFolder)episode$($fileNoStart).$($OutputFileExt)"

    $FileNoStart = $FileNoStart + 1
    $StartTime = $time
}