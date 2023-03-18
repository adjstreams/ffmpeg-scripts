param (
    [string]$title = "MOST PLAYED THIS WEEK",
    [string]$subtitle = "ON SPOTIFY",
    [string]$input_dir = (Get-Location).Path,
    [string]$output_dir = "output",
	[string]$bg_video_dir = "background_videos",
	[string]$font = "BebasNeue-Regular.ttf",
	[string]$logo_image = "logo.png",
    [string]$genre = ""	
)

function Show-Usage {
    $scriptName = Split-Path -Path $MyInvocation.ScriptName -Leaf
    Write-Host "Invalid usage:"
    Write-Host "  .\$scriptName [-title <title_text>] [-subtitle <subtitle_text>] [-input_dir <input_directory>] [-output_dir <output_directory>] [-bg_video_dir <background_video_directory>] [-font <font_file>] [-logo_image <logo_image_file>] [-genre <genre_prefix>]"
    exit
}

$validParameters = @("title", "subtitle", "input_dir", "output_dir", "bg_video_dir", "font", "logo_image", "genre")

for ($i = 0; $i -lt $args.Count; $i += 2) {
    $parameterName = $args[$i].TrimStart('-')
    if ($parameterName -notin $validParameters) {
        Show-Usage
    }
}

$ErrorActionPreference = "Stop"

$bg_video = ""
$clip_start = 60
$clip_duration = 30
$fade_out = $clip_duration - 1

$ffmpeg_outputs = @("-map", "`"[vout]`"", "-map", "`"[audio]`"", "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-c:a", "aac", "-strict", "-2", "-shortest")
$afade_filter = "[1:a]afade=t=in:st=0:d=3,afade=t=out:st=$($fade_out):d=1[audio]"

$count = 0
$files = @()


if ($genre -ne "") {
    write-Host "genre is $genre"
    $bg_video_filter = "$($genre)_*.mp4"
} else {
    $bg_video_filter = "*.mp4"
}

Write-Host "Using filter $bg_video_filter"

Get-ChildItem -Path $bg_video_dir -Filter $bg_video_filter | ForEach-Object {
    $files += $_.FullName
    $count++
}

$count--

if ($input_dir -like "*.mp3") {
    $filter = Split-Path $input_dir -Leaf
    $input_dir = Split-Path $input_dir -Parent
} else {
    $filter = "*.mp3"
}

Get-ChildItem -Path $input_dir -Filter $filter | ForEach-Object {
    $randomIndex = (Get-Random -Maximum ($count + 1))
    $bg_video = $files[$randomIndex]
    Write-Host "Using $bg_video"

	$ffmpeg_inputs = @("-stream_loop", "-1", "-t", $clip_duration, "-i", "`"$bg_video`"", "-ss", $clip_start, "-t", $clip_duration, "-i", "`"$($_.FullName)`"", "-i", "`"$logo_image`"")

    Write-Host "GENERATING 1920 X 1080 clip"
    &ffmpeg $ffmpeg_inputs -filter_complex "`"[0:v]scale=1920x1080,setpts=PTS-STARTPTS[bkg];$afade_filter;[2:v]scale=400:-1,setsar=1[logo];[bkg][logo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg1];[1:a]showwaves=s=1920x200:mode=cline:colors=white[audioviz];[bg1][audioviz]overlay=0:main_h-overlay_h[v];[v]drawtext=fontfile=$($font):text='$($_.BaseName)':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=h-250,drawtext=fontfile=$($font):text='$title':fontcolor=white:fontsize=120:x=(w-text_w)/2:y=30,drawtext=fontfile=$($font):text='$subtitle':fontcolor=white:fontsize=100:x=(w-text_w)/2:y=30+text_h+50[vout]`"" $ffmpeg_outputs "$output_dir\$($_.BaseName)_1920x1080.mp4"
	
	Write-Host "GENERATING 1080 X 1920 clip"
	ffmpeg $ffmpeg_inputs -filter_complex "`"[0:v]scale=-1:1920,crop=1080:1920:(iw-1080)/2:0,setpts=PTS-STARTPTS[bkg];$afade_filter;[2:v]scale=600:-1,setsar=1[logo];[bkg][logo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg1];[1:a]showwaves=s=1080x400:mode=cline:colors=white[audioviz];[bg1][audioviz]overlay=0:main_h-overlay_h[v];[v]drawtext=fontfile=$($font):text='$title':fontcolor=white:fontsize=120:x=(w-text_w)/2:y=55,drawtext=fontfile=$($font):text='$subtitle':fontcolor=white:fontsize=100:x=(w-text_w)/2:y=30+text_h+100,drawtext=fontfile=$($font):text='$($_.BaseName)':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=h-500[vout]`"" $ffmpeg_outputs "$output_dir\$($_.BaseName)_1080x1920.mp4"
}
