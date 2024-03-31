//
//  ContentView.swift
//  mealfriend Watch App
//
//  Created by Kaita on 2024/03/31.
//

import SwiftUI
import WatchConnectivity

struct ContentView: View {
    @ObservedObject var session = WatchSessionDelegate()
    
    var body: some View {
        ScrollView {
            Text("Reachable: \(session.reachable.description)")
            Button("Refresh") { session.refresh() }
            Spacer().frame(height: 8)
            Button("Send") { session.sendMessage(["data": "Hello"]) }
            Spacer().frame(height: 8)
            Text("Log")
            ForEach(session.log.reversed(), id: \.self) {
                Text($0)
            }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
