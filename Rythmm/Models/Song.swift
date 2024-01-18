//
//  Song.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import Foundation

struct Song: Identifiable {
    let id: UUID
    let name: String
    let url: URL
    let songData: SongData
    
    init(id: UUID = UUID(), name: String, url: URL, songData: SongData) {
        self.id = id
        self.name = name
        self.url = url
        self.songData = songData
    }
}
