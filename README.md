# ffmpeg-scripts

## concatenate.ps1

- take a bunch of MP4s and join them together with a duration of x seconds per clip
- Can specify a max duration for the output clip, e.g. 60 seconds
- If the total number of clips x duration is more than max duration, it will split into multiple output files
- USAGE: .\concatenate.ps1 [-duration 5] [-maxDuration 60] [-outputFileName output.mp4] -folderPath /path/to/mp4s
- -folderPath also supports patterns like /path/to/mp4s/*_1920x1080.mp4
- -duration defaults to 5 seconds if not specified
- maxDuration defaults to 60 seconds if not specified
- output file name defaults to output.mp4 if not specified

## create-music-videos.ps1

- Used by SafeBeatz to quickly generate full length music videos for YouTube
- Loop through a folder of MP3s
- Generate a 1920x1080 MP4 for each song
- Uses a loopable background - can be filtered by -genre
- Adds the song title to the video
- Adds an image centrally (i.e. logo or album cover)
- Adds an audio visualization waveform
 
## create-video-clips.ps1

- Used by SafeBeatz to simplify Social media activity.
- Loop through a folder of MP3s
- Generate a 1920x1080 MP4 and a 1080x1920 tall video for each song
- Uses a loopable background video - can be filtered by -genre
- Adds the song title to the video
- Adds an image centrally (i.e. logo or album cover)
- Adds an audio visualization waveform
- Fades the clip in and out (3 second fade in, 1 second fade out)
