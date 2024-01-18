//
//  ContentView.swift
//  Rythmm Watch App
//
//  Created by Dominik Deren on 04/01/2024.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var player: WatchPlayer
    var body: some View {
        VStack {
            Image(systemName: player.topIcon)
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text(player.message)
                .lineLimit(1)
                .truncationMode(/*@START_MENU_TOKEN@*/.tail/*@END_MENU_TOKEN@*/)
            if player.extendedSessionDelegator.extendedSession.state == .running {
                Image(systemName: "figure.socialdance")
            } else {
                Image(systemName: "person.slash")
            }
        }
        .padding()
    }
}

#Preview {
    ContentView(player: WatchPlayer(sessionDelegator: SessionDelegator(), extendedSessionDelegator: ExtendedSessionDelegator()))
}
