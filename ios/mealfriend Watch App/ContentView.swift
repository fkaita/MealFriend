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
    @State private var timeElapsed = 0
    @State private var timerRunning = false
    @State private var showAlert = false
    let images = ["eatingFace1", "eatingFace2", "eatingFace3"]
    @State private var imageIndex = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack {
//            Spacer()
            Image(images[imageIndex])
                .resizable()
                .scaledToFit()
                .frame(minWidth: 120, minHeight: 120)
                .onReceive(timer) { _ in
                    if self.timerRunning{
                        // Count timer
                        timeElapsed += 1
                        
                        // Move to the next image, loop back to the first image after the last one
                        imageIndex = (imageIndex + 1) % images.count
                    }
                }
                .onTapGesture {
                    if self.timerRunning {
                        // If the timer is already running, show the alert
                        self.stopTimer()
                        self.showAlert = true
                    } else {
                        // If the timer is not running, start the timer
                        self.startTimer()
                    }
                }
                .alert(isPresented: $showAlert) {
                    Alert(title: Text("Meal time: \(timeElapsed / 60) minutes"), message: Text("Do you want to continue or finish?"),
                          primaryButton: .default(Text("Continue")) {
                              self.startTimer()
                          },
                          secondaryButton: .cancel(Text("Finish")) {
                              self.timeElapsed = 0
                          })
                }
                Spacer()
            
            // Progress Bar at the bottom
                ProgressView(value: Double(timeElapsed), total: 900.0)
                    .progressViewStyle(LinearProgressViewStyle()) // Use Linear style
                    .scaleEffect(x: 1, y: 0.8, anchor: .center)
                    .padding()
        }
    }

    func startTimer() {
        timerRunning = true
    }
    
    func stopTimer() {
        timerRunning = false
    }
}

#Preview {
    ContentView()
}
