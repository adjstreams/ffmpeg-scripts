@echo off
setlocal enabledelayedexpansion
set "FONT=BebasNeue-Regular.ttf"
set "BG_VIDEO=edm_bg.mp4"
set "LOGO_IMAGE=logo.png"
set "OUTPUT_DIR=output"
set "CLIP_START=60"
set "CLIP_DURATION=30"
set /a "FADE_OUT=CLIP_DURATION-1"
set "SUBTITLE=CHECK THIS OUT"

set "INPUT_DIR=%cd%"

:parse_args
if "%~1"=="" goto main

if "%~1"=="-i" (
  shift
  set "INPUT_DIR=%~1"
) else if "%~1"=="-o" (
  shift
  set "OUTPUT_DIR=%~1"
) else if "%~1"=="-s" (
  shift
  set "SUBTITLE=%~1"
) else (
  echo Invalid argument: %1
  goto usage
)
shift
goto parse_args

:usage
echo Usage: %0 [-i input_dir] [-o output_dir] [-s subtitle]
goto end

:main
for %%i in ("%INPUT_DIR%\*.mp3") do (
  ffmpeg -stream_loop -1 -t %CLIP_DURATION% -i "%BG_VIDEO%" -ss %CLIP_START% -t %CLIP_DURATION% -i "%%i" -i "%LOGO_IMAGE%" -filter_complex "[0:v]scale=1920x1080,setpts=PTS-STARTPTS[bkg];[1:a]afade=t=in:st=0:d=3,afade=t=out:st=!FADE_OUT!:d=1[audio];[2:v]scale=400:-1,setsar=1[logo];[bkg][logo]overlay=(main_w-overlay_w)/2:(main_h-overlay_h)/2[bg1];[bg1]drawtext=fontfile=!FONT!:text='%%~ni':fontcolor=white:fontsize=72:x=(w-text_w)/2:y=h-80,drawtext=fontfile=!FONT!:text='%SUBTITLE%':fontcolor=white:fontsize=120:x=(w-text_w)/2:y=30[v]" -map "[v]" -map "[audio]" -c:v libx264 -preset medium -crf 18 -c:a aac -strict -2 -shortest "%OUTPUT_DIR%\%%~ni.mp4"
)

:end
