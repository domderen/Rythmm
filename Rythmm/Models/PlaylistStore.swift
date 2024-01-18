//
//  PlaylistStore.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import Foundation

@MainActor
class PlaylistStore: ObservableObject {
    @Published var playlists: [Playlist] = []
    
    private static func docsURL() throws -> URL {
        try FileManager.default.url(for: .documentDirectory,
                                    in: .userDomainMask,
                                    appropriateFor: nil,
                                    create: false)
    }
    
    // Make sure there is at least one file in the app's Documents directory,
    // so that user could move music there using the Files app.
    init() {
        do {
            let docsURL = try Self.docsURL()
            let fileURL = docsURL.appendingPathComponent("empty")
            self.createEmptyFile(at: fileURL)
        } catch {
            fatalError("Failed to initialize PlaylistStore \(error)")
        }
    }
    
    func createEmptyFile(at url: URL) {
        let fileManager = FileManager.default
        
        // Check if the file already exists
        if !fileManager.fileExists(atPath: url.path) {
            // Create an empty file
            fileManager.createFile(atPath: url.path, contents: nil, attributes: nil)
        }
    }
    
    func createPlaylist(playlistDir: URL) throws -> Playlist {
        let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
        
        // Get an enumerator for the directory's content.
        guard let songsDirEnumeration =
                FileManager.default.enumerator(at: playlistDir, includingPropertiesForKeys: keys, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]) else {
            fatalError("*** Unable to access the contents of \(playlistDir.path) ***\n")
        }
        
        var songs: [Song] = []
        
        for case let songUrl as URL in songsDirEnumeration {
            let songFileName = songUrl.lastPathComponent
            if !songUrl.hasDirectoryPath && (songFileName.hasSuffix(".mp3") || songFileName.hasSuffix(".wav")) {
                let songDataFileName = replaceStringUsingRegex(input: songFileName, pattern: "\\.(wav|mp3)$", replacement: ".json")
                let songDataUrl = playlistDir.appendingPathComponent("struct").appendingPathComponent(songDataFileName)
                let songData = try SongData.fromFile(url: songDataUrl)
                let songName = songDataFileName.replacingOccurrences(of: ".json", with: "")
                let song = Song(name: songName, url: songUrl, songData: songData)
                songs.append(song)
            }
        }
        
        return Playlist(url: playlistDir, songs: songs)
    }
    
    func createPlaylists() throws -> [Playlist] {
        let documentsURL = try Self.docsURL()
        
        let keys : [URLResourceKey] = [.nameKey, .isDirectoryKey]
        
        // Get an enumerator for the directory's content.
        guard let documentsEnumeration =
                FileManager.default.enumerator(at: documentsURL, includingPropertiesForKeys: keys, options: [.skipsSubdirectoryDescendants, .skipsHiddenFiles]) else {
            fatalError("*** Unable to access the contents of \(documentsURL.path) ***\n")
        }
        
        var playlists: [Playlist] = []
        
        for case let url as URL in documentsEnumeration {
            if url.hasDirectoryPath {
                let playlist = try self.createPlaylist(playlistDir: url)
                playlists.append(playlist)
            }
        }
        
        return playlists
    }
    
    func load() async throws {
        let task = Task<[Playlist], Error> {
            return try self.createPlaylists()
        }
        let playlists = try await task.value
        self.playlists = playlists
    }
}
