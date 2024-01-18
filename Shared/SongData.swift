//
//  SongData.swift
//  Rythmm
//
//  Created by Dominik Deren on 04/01/2024.
//

import Foundation

struct SongData: Codable {
    struct Segment: Codable {
        let start: Double
        let end: Double
        let label: String
    }
    
    struct HapticSequence: Codable {
        let playTime: Double
        let playDate: Date
        let isDownbeat: Bool
        let isOne: Bool
    }
    
    let path: String
    let bpm: Int
    let beats: [Double]
    let downbeats: [Double]
    let beatPositions: [Int]
    let segments: [Segment]
    
    enum SongDataParsingError: Error {
        case noData
    }
    
    static func fromFile(url: URL) throws -> Self {
        guard let data = try? Data(contentsOf: url) else {
            throw SongDataParsingError.noData
        }
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        let songData = try decoder.decode(Self.self, from: data)
        return songData
    }
    
    func generateHapticSequence(startTime: Double, startDate: Date) -> [HapticSequence] {
        var isOne = false
        return zip(self.beats, self.beatPositions).map({ (beatTime, beatPosition) in
            if beatPosition == 1 {
                isOne = !isOne
            }
            return HapticSequence(
                playTime: startTime+beatTime,
                playDate: startDate.addingTimeInterval(beatTime),
                isDownbeat: beatPosition == 1,
                isOne: beatPosition == 1 && isOne ? true : false)
        })
    }
}

enum MessageType: String, Codable {
    case songUpdated = "songUpdated"
    case playbackStarted = "playbackStarted"
    case playbackStopped = "playbackStopped"
    case hapticPlaybackUpdated = "hapticPlaybackUpdated"
}

struct WatchMessage: Codable {
    let messageType: MessageType
    let song: SongData?
    let songName: String?
    let playbackStartDate: Date?
    let shouldPlayWatchHaptics: Bool
}
