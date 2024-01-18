//
//  ContentView.swift
//  Rythmm
//
//  Created by Dominik Deren on 04/01/2024.
//

import SwiftUI
import AVKit

struct PlaylistsView: View {
    @ObservedObject var player: Player
    @Binding var playlists: [Playlist]
    var body: some View {
        NavigationStack {
            List($playlists) { $playlist in
                NavigationLink(playlist.name, destination: SongsView(player: player, playlist: $playlist))
            }
            .navigationTitle("Playlists")
        }
    }
}

#Preview {
    PlaylistsView(player: Player(sessionDelegator: SessionDelegator()), playlists: .constant(Playlist.sampleData))
}
