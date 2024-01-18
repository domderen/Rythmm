//
//  SongsView.swift
//  Rythmm
//
//  Created by Dominik Deren on 12/01/2024.
//

import SwiftUI

struct SongsView: View {
    @ObservedObject var player: Player
    @Binding var playlist: Playlist
    var body: some View {
        NavigationStack {
            List($playlist.songs) { $song in
                NavigationLink(song.name, destination: PlayerView(player: player, song: $song))
            }
            .navigationTitle("\(playlist.name) songs")
        }
    }
}

#Preview {
    SongsView(player: Player(sessionDelegator: SessionDelegator()), playlist: .constant(Playlist.sampleData[0]))
}
