//
//  WatchPlayer.swift
//  Rythmm Watch App
//
//  Created by Dominik Deren on 05/01/2024.
//

import Foundation
import WatchConnectivity
import WatchKit

class WatchPlayer: ObservableObject {
    private(set) var sessionDelegator: SessionDelegator
    @Published var extendedSessionDelegator: ExtendedSessionDelegator
    @Published var topIcon: String = "music.note"
    @Published var message: String = "No song yet"
    @Published var extendedSessionStarted: Bool = false
    @Published var shouldPlayWatchHaptics: Bool = false
    @Published var isSongPlaying: Bool = false
    private var songData: SongData?
    private var songStartDate: Date?
    private var timers: [Timer] = []
    
    init(sessionDelegator: SessionDelegator, extendedSessionDelegator: ExtendedSessionDelegator) {
        self.sessionDelegator = sessionDelegator
        self.extendedSessionDelegator = extendedSessionDelegator
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).dataDidFlow(_:)),
            name: .dataDidFlow, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).activationDidComplete(_:)),
            name: .activationDidComplete, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).reachabilityDidChange(_:)),
            name: .reachabilityDidChange, object: nil
        )
        
        NotificationCenter.default.addObserver(
            self, selector: #selector(type(of: self).extendedSessionStarted(_:)),
            name: ExtendedSessionDelegator.sessionStarted, object: nil
        )
    }
    @objc
    func extendedSessionStarted(_ notification: Notification) {
        self.extendedSessionStarted = true
    }
    
    // .activationDidComplete notification handler.
    //
    @objc
    func activationDidComplete(_ notification: Notification) {
        print("Got notification on watch: \(notification)")
    }
    
    // .reachabilityDidChange notification handler.
    //
    @objc
    func reachabilityDidChange(_ notification: Notification) {
        print("Got notification on watch: \(notification)")
    }
    
    @objc
    func playDownbeatHaptic() {
        if self.isSongPlaying {
            WKInterfaceDevice.current().play(.failure)
        }
    }
    
    @objc
    func playBeatHaptic() {
        if self.isSongPlaying {
            WKInterfaceDevice.current().play(.success)
        }
    }
    
    private func startHaptics() {
        if self.shouldPlayWatchHaptics {
            let hapticSequence = self.songData!.generateHapticSequence(startTime: 0, startDate: self.songStartDate!)
            for haptic in hapticSequence {
                if haptic.isDownbeat {
                    let timer: Timer
                    if haptic.isOne {
                        timer = Timer(fireAt: haptic.playDate.addingTimeInterval(-0.1), interval: 0, target: self, selector: #selector(playDownbeatHaptic), userInfo: nil, repeats: false)
                    } else {
                        timer = Timer(fireAt: haptic.playDate.addingTimeInterval(-0.1), interval: 0, target: self, selector: #selector(playBeatHaptic), userInfo: nil, repeats: false)
                    }
                    
                    RunLoop.main.add(timer, forMode: .common)
                    self.timers.append(timer)
                }
            }
        }
    }
    
    private func stopHaptics() {
        for timer in timers {
            timer.invalidate()
        }
    }
    
    // .dataDidFlow notification handler.
    // Update the UI using the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        guard let data = notification.object as? Data else { return }
        do {
            let decoder = JSONDecoder()
            let watchMessage = try decoder.decode(WatchMessage.self, from: data)
            print("Got command on watch: \(watchMessage.messageType)")
            self.shouldPlayWatchHaptics = watchMessage.shouldPlayWatchHaptics
            switch(watchMessage.messageType) {
            case .songUpdated:
                self.songData = watchMessage.song
                self.message = watchMessage.songName!
            case .playbackStarted:
                self.topIcon = "play.circle"
                self.songStartDate = watchMessage.playbackStartDate
                self.isSongPlaying = true
                self.startHaptics()
            case .playbackStopped:
                self.topIcon = "pause.circle"
                self.isSongPlaying = false
                self.stopHaptics()
            case .hapticPlaybackUpdated:
                if self.shouldPlayWatchHaptics {
                    self.startHaptics()
                } else {
                    self.stopHaptics()
                }
            }
        } catch {
            print("Failed to decode message from iOS! \(error)")
        }
    }
}

