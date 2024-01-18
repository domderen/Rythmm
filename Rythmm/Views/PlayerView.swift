//
//  PlayerView.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import SwiftUI

struct PlayerView: View {
    @ObservedObject var player: Player
    @Binding var song: Song
    var body: some View {
        VStack {
            VStack {
                Text("Playback time")
                Text("\(player.currentTime) / \(player.songDuration)")
            }
            HStack {
                Button {
                    player.play()
                } label: {
                    Image(systemName: "play.circle")
                }
                .disabled(player.isPlaying)
                .padding()
                Button {
                    player.pause()
                } label: {
                    Image(systemName: "pause.circle")
                }
                .disabled(!player.isPlaying)
                .padding()
                Button {
                    player.stop()
                } label: {
                    Image(systemName: "stop.circle")
                }
                .disabled(!player.isPlaying)
                .padding()
            }
            .padding()
            HStack {
                Button {
                    player.flipShouldPlayPhoneHaptics()
                } label: {
                    Image(systemName: player.shouldPlayPhoneHaptics ? "iphone" : "iphone.slash")
                }
                .padding()
                Button {
                    player.flipShouldPlayWatchHaptics()
                } label: {
                    Image(systemName: player.shouldPlayWatchHaptics ? "applewatch" : "applewatch.slash")
                }
                .padding()
            }
            .padding()
            HStack {
                Text("Watch is \(player.sessionDelegator.session.isReachable ? "active" : "unavailable")")
                .padding()
            }
            .padding()
        }
        .font(.largeTitle)
        .navigationTitle(song.name)
        .task {
            player.setSong(song: song)
        }
        .onDisappear {
            player.stop()
        }
    }
}

#Preview {
    PlayerView(player: Player(sessionDelegator: SessionDelegator()), song: .constant(Playlist.sampleData[0].songs[0]))
}
