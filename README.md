# Rythm

iOS media player that lets you feel the rythm :dancer:
 
 ![App icon.](Rythmm/Assets.xcassets/AppIcon.appiconset/128.png)
 

An iOS and Watch media player that provides haptic feedback for the music's rythm. Play a song from app's library, and both iOS & Watch applications can provide haptic feedback informing you of the first downbeat of a bar. It differenciates between an odd & even bars (the first & fifth beat) to help dancers find their way around the song.

## Uploading songs

Application requires uploading songs & their beat information into the app's Documents folder on iOS device via the "Files" application. before uploading songs, they should first be pre-processed via [All-In-One Music Structure Analyzer](https://github.com/mir-aidj/all-in-one) to generate JSON files with beat positions for a given song.

Next songs & JSON files should be copied to app's on device directory in folder structure:
-> On My iPhone
  -> Rythmm
    -> <new directory with playlist name> - upload your songs to this directory. MP3 & WAV files are supported.
      -> struct - new directory that should contain all JSON files for your songs. JSON files & song files should have the same name, and just different file extensions.

## TODOs

- [x] Provide haptic feedback for songs
- [ ] Allow easier upload & generation of JSON files for songs
- [ ] Provide optional visual feedback for songs 
- [ ] Provide optional sound feedback for songs' downbeat info
- [ ] Improve app's visual outlook 
