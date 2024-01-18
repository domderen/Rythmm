//
//  Playlist.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import Foundation

struct Playlist: Identifiable {
    let id: UUID
    let url: URL
    var songs: [Song]
    
    var name: String {
        url.lastPathComponent
    }
    
    init(id: UUID = UUID(), url: URL, songs: [Song]) {
        self.id = id
        self.url = url
        self.songs = songs
    }
}

extension Playlist {
    static let sampleData: [Playlist] = [
        Playlist(url: URL(string: "/path/to/rock")!,
                 songs: [
            Song(name: "Song 1", url: URL(string: "/path/to/rock")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
            Song(name: "Song 2", url: URL(string: "/path/to/rock")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
            Song(name: "Song 3", url: URL(string: "/path/to/rock")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
        ]),
        Playlist(url: URL(string: "/path/to/cha_cha")!,
                 songs: [
            Song(name: "Song 1", url: URL(string: "/path/to/cha_cha")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
            Song(name: "Song 2", url: URL(string: "/path/to/cha_cha")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
            Song(name: "Song 3", url: URL(string: "/path/to/cha_cha")!, songData: SongData(path: "", bpm: 120, beats: [1,2,3], downbeats: [1,2,3], beatPositions: [1,2,3], segments: [])),
        ])
    ]
}
