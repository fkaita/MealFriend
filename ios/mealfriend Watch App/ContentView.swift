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
    let previousRecordKey = "previous_record"
    @State private var imageIndex = 0
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var checkConnectionTimer: Timer? = nil
    
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
                        // Get the current date and time
                        let now = Date()
                        // Create an instance of DateFormatter
                        let formatter = DateFormatter()
                        // Set the date format
                        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                        // Convert the date to a string
                        let dateString = formatter.string(from: now)
                        // Reflesh session to get updated status
                        session.refresh()
                        if (session.reachable){
                            // Send message to phone
                            session.sendMessage(["data": "\(dateString),\(timeElapsed)"])
                        }else{
                            UserDefaults.standard.set("\(dateString),\(timeElapsed)", forKey: previousRecordKey)
                        }
                    
                        // Reset time
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
        .onAppear {
            self.checkConnectionTimer = Timer.scheduledTimer(withTimeInterval: 10.0, repeats: true) { _ in
                self.checkConnectionAndSendData()
            }
        }
        .onDisappear {
            self.checkConnectionTimer?.invalidate()
            self.checkConnectionTimer = nil
        }
    }
    

    func startTimer() {
        timerRunning = true
        session.sendMessage(["staus": "started"])
    }
    
    func stopTimer() {
        timerRunning = false
        session.sendMessage(["staus": "stopped"])
    }

    // Method to check connection and send data
    func checkConnectionAndSendData() {
        // Refresh session to get updated status
        session.refresh()
        if session.reachable {
            // Get all keys from UserDefaults
            let value = UserDefaults.standard.object(forKey: previousRecordKey) as? String
            // Send message to phone
            session.sendMessage(["data": value ?? ""])
            // Remove the key-value pair from UserDefaults
            UserDefaults.standard.removeObject(forKey: previousRecordKey)
        }
    }
}

#Preview {
    ContentView()
}
