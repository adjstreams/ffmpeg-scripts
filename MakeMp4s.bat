for %%a in (*.wav) do "ffmpeg" -loop 1 -i image.png -i "%%a" -s 1920x1080 -b:a 192k -vf format=yuv420p -c:a aac -c:v libx264 -shortest "%%~na.mp4"
