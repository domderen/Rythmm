//
//  RythmmApp.swift
//  Rythmm
//
//  Created by Dominik Deren on 04/01/2024.
//

import SwiftUI

@main
struct RythmmApp: App {
    @StateObject private var store = PlaylistStore()
    @StateObject var player = Player(sessionDelegator: SessionDelegator())
    @State private var errorWrapper: ErrorWrapper?
    var body: some Scene {
        WindowGroup {
            PlaylistsView(player: player, playlists: $store.playlists)
                .task {
                    do {
                        try await store.load()
                    } catch {
                        errorWrapper = ErrorWrapper(error: error, guidance: "Try again later.")
                    }
                }
                .sheet(item: $errorWrapper, content: { wrapper in
                    ErrorView(errorWrapper: wrapper)
                })
        }
    }
}
