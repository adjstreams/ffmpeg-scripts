param (
    [string]$FolderPath,
    [int]$duration=5
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

# Use ffmpeg to concatenate the mp4 files, including only the first few seconds of each clip
$cmd = "ffmpeg.exe"
for ($i = 0; $i -lt $files.Count; $i++) {
    $cmd += " -ss 0 -to $duration -r 30 -i $($filesList[$i])"
}
$cmd += " -filter_complex 'concat=n=$($files.Count):v=1:a=1[out]' -map '[out]' -r 30 -y output.mp4"
Invoke-Expression $cmd
