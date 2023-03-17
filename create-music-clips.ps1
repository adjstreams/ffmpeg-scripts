param (
    [string]$subtitle = "MOST PLAYED THIS WEEK",
    [string]$input_dir = (Get-Location).Path,
    [string]$output_dir = "output",
	  [string]$bg_video_dir = "background_videos",
	  [string]$font = "BebasNeue-Regular.ttf",
	  [string]$logo_image = "logo.png",
    [string]$genre = ""	
)

$ErrorActionPreference = "Stop"

$bg_video = ""
$clip_start = 60
$clip_duration = 30
$fade_out = $clip_duration - 1

$ffmpeg_outputs = @("-map", "`"[vout]`"", "-map", "`"[audio]`"", "-c:v", "libx264", "-preset", "medium", "-crf", "18", "-c:a", "aac", "-strict", "-2", "-shortest")
$afade_filter = "[1:a]afade=t=in:st=0:d=3,afade=t=out:st=$($fade_out):d=1[audio]"

$count = 0
$files = @()


if ($genre) {
    $bg_video_filter = "$genre_*.mp4"
} else {
    $bg_video_filter = "*.mp4"
}

Get-ChildItem -Path $bg_video_dir -Filter $bg_video_filter | ForEach-Object {
    $files += $_.FullName
    $count++
}

$count--

Get-ChildItem -Path $input_dir -Filter "*.mp3" | ForEach-Object {
    $randomIndex = (Get-Random -Maximum ($count + 1))
    $bg_video = $files[$randomIndex]

	$ffmpeg_inputs = @("-stream_loop", "-1", "-t", $clip_duration, "-i", "`"$bg_video`"", "-ss", $clip_start, "-t", $clip_duration, "-i", "`"$($_.FullName)`"", "-i", "`"$logo_image`"")

    Write-Host "GENERATING 1920 X 1080 clip"
    &ffmpeg $ffmpeg_inputs -filter_complex "`"[0:v]scale=1920x1080,setpts=PTS-STARTPTS[bkg];$afade_filter;[2:v]scale=400:-1,setsar=1[logo];[bkg][logo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg1];[1:a]showwaves=s=1920x200:mode=p2p:colors=white[audioviz];[bg1][audioviz]overlay=0:main_h-overlay_h[v];[v]drawtext=fontfile=$($font):text='$($_.BaseName)':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=h-80,drawtext=fontfile=$($font):text='$subtitle':fontcolor=white:fontsize=120:x=(w-text_w)/2:y=30[vout]`"" $ffmpeg_outputs "$output_dir\$($_.BaseName)_1920x1080.mp4"
	
	Write-Host "GENERATING 1080 X 1920 clip"
	ffmpeg $ffmpeg_inputs -filter_complex "`"[0:v]scale=-1:1920,crop=1080:1920:(iw-1080)/2:0,setpts=PTS-STARTPTS[bkg];$afade_filter;[2:v]scale=400:-1,setsar=1[logo];[bkg][logo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg1];[1:a]showwaves=s=1080x400:mode=p2p:colors=white[audioviz];[bg1][audioviz]overlay=0:main_h-overlay_h[v];[v]drawtext=fontfile=$($font):text='$subtitle':fontcolor=white:fontsize=120:x=(w-text_w)/2:y=55,drawtext=fontfile=$($font):text='$($_.BaseName)':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=15+text_h+130[vout]`"" $ffmpeg_outputs "$output_dir\$($_.BaseName)_1080x1920.mp4"
}
