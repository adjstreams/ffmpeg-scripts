# ffmpeg-scripts

## MakeMP4s.bat

- Used by SafeBeatz to quickly generate music videos for YouTube.
- Loop through a folder of MP3s
- Generate a 1920x1080 MP4 for each song, using a static image.
 
## create-video-clips.bat

usage: create-video-clips.bat [-i input_dir] [-o output_dir] [-s subtitle]

- Used by SafeBeatz to simplify Social media activity.
- Loop through a folder of MP3s
- Generate a 1920x1080 MP4 and a 1080x1920 tall video for each song
- Uses a loopable background video.
- Adds the song title to the video
- Adds a logo positioned centrally
- Adds an audio visualization waveform
- Fades the clip in and out

Next steps:

- Add support for picking a random video based on genre specified
- Refactor to reduce duplicated setup in the filter_complex arguments
