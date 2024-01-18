//
//  Player.swift
//  Rythmm
//
//  Created by Dominik Deren on 04/01/2024.
//

import Foundation
import CoreHaptics
import AVFoundation
import WatchConnectivity
import Combine

class Player: ObservableObject {
    static private func loadPattern(_ name: String) -> CHHapticPattern {
        guard let patternUrl = Bundle.main.url(forResource: name, withExtension: ".ahap") else {
            fatalError("Downbeat not found!")
        }
        do {
            return try CHHapticPattern(contentsOf: patternUrl)
        } catch {
            fatalError("Failed to initialze a haptic pattern \(error)")
        }
    }
    
    static private var downbeat: CHHapticPattern {
        loadPattern("Downbeat")
    }
    
    static private var beat: CHHapticPattern {
        loadPattern("Beat")
    }
    
    private(set) var sessionDelegator: SessionDelegator
    // A haptic engine manages the connection to the haptic server.
    private var hapticEngine: CHHapticEngine?
    private var timeObserverToken: Any?
    private var statusObservation: AnyCancellable?
    private var startTimeObserverToken: Any?
    private var song: Song?
    private var playerItem: AVPlayerItem?
    private var songStartTime: Double?
    private var songStartTimeDate: Date?
    private var player: AVPlayer
    private var hapticPlayers: [CHHapticPatternPlayer] = []
    private var unsentWatchMessages: [WatchMessage] = []
    @Published var isPlaying = false
    @Published private(set) var shouldPlayPhoneHaptics = true
    @Published private(set) var shouldPlayWatchHaptics = true
    @Published var currentTime: String = "00:00"
    @Published var songDuration: String = "00:00"
    
    init(sessionDelegator: SessionDelegator) {
        do {
            self.sessionDelegator = sessionDelegator
            self.player = AVPlayer(playerItem: nil)
            self.player.allowsExternalPlayback = true
            let interval = CMTime(seconds: 1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
            timeObserverToken = self.player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak self] time in
                self?.updateCurrentTime(time: time)
            }
            guard CHHapticEngine.capabilitiesForHardware().supportsHaptics else {
                Swift.debugPrint("Device does not support haptics!.")
                return
            }
            let audioSession = AVAudioSession.sharedInstance()
            try audioSession.setCategory(.playback,
                                         mode: .default,
                                         policy: .longFormAudio)
            try audioSession.setActive(true)
            self.hapticEngine = Self.createEngine()
            
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
        } catch {
            fatalError("Failed to initialie player.")
        }
    }

    /// - Tag: CreateEngine
    static func createEngine() -> CHHapticEngine {
        let eng: CHHapticEngine?
        do {
            // Create and configure a haptic engine.
            eng = try CHHapticEngine()
            try eng!.start()
        } catch {
            fatalError("Failed to initialize haptic engine")
        }
        
        guard let engine = eng else { fatalError("No haptic engine!") }
        
        engine.playsHapticsOnly = true
        // The stopped handler alerts you of engine stoppage due to external causes.
        engine.stoppedHandler = { reason in
            print("The engine stopped for reason: \(reason.rawValue)")
            switch reason {
            case .audioSessionInterrupt:
                print("Audio session interrupt")
            case .applicationSuspended:
                print("Application suspended")
            case .idleTimeout:
                print("Idle timeout")
            case .systemError:
                print("System error")
            case .notifyWhenFinished:
                print("Playback finished")
            case .gameControllerDisconnect:
                print("Controller disconnected.")
            case .engineDestroyed:
                print("Engine destroyed.")
            @unknown default:
                print("Unknown error")
            }
        }
        
        // The reset handler provides an opportunity for your app to restart the engine in case of failure.
        engine.resetHandler = {
            // Try restarting the engine.
            print("The engine reset --> Restarting now!")
            do {
                try engine.start()
            } catch {
                print("Failed to restart the engine: \(error)")
            }
        }
        return engine
    }
    
    func setSong(song: Song) {
        statusObservation?.cancel()
        self.song = song
        self.playerItem = AVPlayerItem(url: song.url)
        self.observePlayerItem(self.playerItem!)
        self.player.replaceCurrentItem(with: self.playerItem)
        self.sendMessage(WatchMessage(messageType: .songUpdated, song: self.song?.songData, songName: self.song!.name, playbackStartDate: nil, shouldPlayWatchHaptics: self.shouldPlayWatchHaptics))
    }
    
    func flipShouldPlayPhoneHaptics() {
        self.shouldPlayPhoneHaptics = !self.shouldPlayPhoneHaptics
        if self.isPlaying {
            if self.shouldPlayPhoneHaptics {
                self.startHapticPlayers()
            } else {
                self.stopHapticPlayers()
            }
        }
    }
    
    func flipShouldPlayWatchHaptics() {
        self.shouldPlayWatchHaptics = !self.shouldPlayWatchHaptics
        self.sendMessage(WatchMessage(messageType: .hapticPlaybackUpdated, song: nil, songName: nil, playbackStartDate: nil, shouldPlayWatchHaptics: self.shouldPlayWatchHaptics))
    }
    
    private func observePlayerItem(_ song: AVPlayerItem) {
        // Observe the status property
        statusObservation = song.publisher(for: \.status)
            .sink { status in
                if status == .readyToPlay {
                    self.songDuration = formatSecondsToMinutesAndSeconds(song.duration.seconds)
                }
            }
    }
    
    func play() {
        self.isPlaying = true
        let interval = CMTime(seconds: 0.1, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        startTimeObserverToken = player.addPeriodicTimeObserver(forInterval: interval, queue: DispatchQueue.main) { time in
            if self.player.currentTime().seconds > 0 {
                self.removeStartTimeObserver()
                self.songStartTime = self.hapticEngine!.currentTime - self.player.currentTime().seconds
                self.songStartTimeDate = Date.now.addingTimeInterval(-self.player.currentTime().seconds)
                if self.shouldPlayPhoneHaptics {
                    self.startHapticPlayers()
                }
                self.sendMessage(WatchMessage(messageType: .playbackStarted, song: nil, songName: nil, playbackStartDate: self.songStartTimeDate, shouldPlayWatchHaptics: self.shouldPlayWatchHaptics))
            }
        }
        self.player.play()
    }
    
    func pause() {
        self.isPlaying = false
        player.pause()
        self.stopHapticPlayers()
        self.sendMessage(WatchMessage(messageType: .playbackStopped, song: nil, songName: nil, playbackStartDate: nil, shouldPlayWatchHaptics: self.shouldPlayWatchHaptics))
    }
    
    func stop() {
        self.isPlaying = false
        player.pause()
        player.seek(to: .zero)
        self.stopHapticPlayers()
        self.sendMessage(WatchMessage(messageType: .playbackStopped, song: nil, songName: nil, playbackStartDate: nil, shouldPlayWatchHaptics: self.shouldPlayWatchHaptics))
    }

    private func removeStartTimeObserver() {
        if let token = startTimeObserverToken {
            player.removeTimeObserver(token)
            startTimeObserverToken = nil
        }
    }
    
    private func removePeriodicTimeObserver() {
        if let token = timeObserverToken {
            player.removeTimeObserver(token)
            timeObserverToken = nil
        }
    }
    
    private func startHapticPlayers() {
        guard let hapticEngine = self.hapticEngine else {
            Swift.debugPrint("Tried playing song without haptic engine instance.")
            return
        }
        guard let song = self.song else {
                Swift.debugPrint("Tried playing song without song instance.")
            return
        }
        let haptics = song.songData.generateHapticSequence(startTime: self.songStartTime!, startDate: self.songStartTimeDate!)
        do {
            for hapticSequence in haptics {
                if hapticEngine.currentTime < hapticSequence.playTime {
                    if hapticSequence.isDownbeat {
                        let hPlayer = try hapticEngine.makePlayer(with: hapticSequence.isOne ? Self.downbeat : Self.beat)
                        try hPlayer.start(atTime: hapticSequence.playTime)
                        self.hapticPlayers.append(hPlayer)
                    }
                }
                
            }
        } catch {
            print("An error occured scheduling haptic patterns: \(error).")
        }
    }
    
    private func stopHapticPlayers() {
        for hPlayer in self.hapticPlayers {
            do {
                try hPlayer.cancel()
            } catch {
                Swift.debugPrint("Got an error cancelling haptic engine \(error)")
            }
        }
        self.hapticPlayers = []
    }
    
    // Send a message if the session is activated, and update the UI with the command status.
    //
    private func sendMessage(_ watchMessage: WatchMessage) {
        guard self.sessionDelegator.session.activationState == .activated && self.sessionDelegator.session.isReachable else {
            self.unsentWatchMessages.append(watchMessage)
            return
        }
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(watchMessage)
            
            // A reply handler block runs asynchronously on a background thread and should return quickly.
            WCSession.default.sendMessageData(data, replyHandler: { _ in }, errorHandler: { error in
                print("Got error while trying to send a msg to watch: \(error)")
            })
        } catch {
            print("Failed to serialize message for watch: \(error)")
        }
    }
    
    private func updateCurrentTime(time: CMTime) {
        self.currentTime = formatSecondsToMinutesAndSeconds(time.seconds)
    }
    
    // .activationDidComplete notification handler.
    //
    @objc
    func activationDidComplete(_ notification: Notification) {
        print("Got notification on ios: \(notification)")
    }
    
    // .reachabilityDidChange notification handler.
    //
    @objc
    func reachabilityDidChange(_ notification: Notification) {
        print("Watch reachability changed on ios: \(notification)")
        if self.sessionDelegator.session.isReachable {
            for message in self.unsentWatchMessages {
                print("sending previously not sent message \(message)")
                self.sendMessage(message)
            }
            self.unsentWatchMessages = []
        }
    }
    
    // .dataDidFlow notification handler.
    // Update the UI using the userInfo dictionary of the notification.
    //
    @objc
    func dataDidFlow(_ notification: Notification) {
        print("Got command on ios: \(notification)")
    }
    
    deinit {
        removeStartTimeObserver()
        removePeriodicTimeObserver()
        statusObservation?.cancel()
    }

}
