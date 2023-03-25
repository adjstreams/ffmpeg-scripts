param (
    [string]$FolderPath,
    [int]$duration = 5,
    [int]$maxDuration = 60,
    [string]$outputFileName = "output.mp4"
)

# Check if the specified path is a directory or a file path
if (Test-Path $FolderPath -PathType Container) {
    # Directory path - get all mp4 files in the directory
    $files = Get-ChildItem $FolderPath -Filter *.mp4
} else {
    # File path with pattern - get all files matching the pattern
    $files = Get-ChildItem -Path $FolderPath
}

# Create a list of file paths to be used in the ffmpeg command
$filesList = foreach ($file in $files) {
    "'{0}'" -f $file.FullName
}

$partsCount = [math]::Ceiling(($files.Count * $duration) / $maxDuration)
$filesPerPart = [math]::Ceiling($files.Count / $partsCount)

for ($p = 0; $p -lt $partsCount; $p++) {
    $cmd = "ffmpeg.exe"
    for ($i = $p * $filesPerPart; $i -lt [math]::Min(($p + 1) * $filesPerPart, $files.Count); $i++) {
        $cmd += " -ss 0 -to $duration -r 30 -i $($filesList[$i])"
    }

    $partSuffix = ""
    if ($partsCount -gt 1) {
        $partSuffix = "_part$($p + 1)"
    }
    $outputFileWithSuffix = [System.IO.Path]::ChangeExtension($outputFileName, "$partSuffix$([System.IO.Path]::GetExtension($outputFileName))")

    $cmd += " -filter_complex 'concat=n=$([math]::Min($filesPerPart, $files.Count - $p * $filesPerPart)):v=1:a=1[out]' -map '[out]' -r 30 -y $outputFileWithSuffix"
    Invoke-Expression $cmd
}
