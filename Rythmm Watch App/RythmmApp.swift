//
//  RythmmApp.swift
//  Rythmm Watch App
//
//  Created by Dominik Deren on 04/01/2024.
//

import SwiftUI

@main
struct Rythmm_Watch_AppApp: App {
    @StateObject var player = WatchPlayer(sessionDelegator: SessionDelegator(), extendedSessionDelegator: ExtendedSessionDelegator())
    @Environment(\.scenePhase) private var scenePhase
    var body: some Scene {
        WindowGroup {
            ContentView(player: player)
        }
        .onChange(of: scenePhase) { (oldValue, newValue) in
            if newValue == .active {
                print("going to active, starting extended session.")
                player.extendedSessionDelegator.start()
            }
        }
    }
}
