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
    @State private var showConfirmation = false
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
//                        self.showAlert = true
                        self.showConfirmation = true
                    } else {
                        // If the timer is not running, start the timer
                        self.startTimer()
                    }
                }
                .confirmationDialog("Meal time: \(timeElapsed / 60) minutes", isPresented: $showConfirmation) {
                    Button("Save", action: saveData)
                    Button("Discard", role: .destructive){
                        self.timeElapsed = 0
                    }
                    Button("Cancel", role: .cancel) {
                        self.startTimer()
                    }
                } message: {
                    Text("Do you want to save or discard meal time?")
                }
                .alert("Coudn't save", isPresented: $showAlert) {
                    Button("Retry") {
                        // retry save
                        saveData()
                    }
                    Button("Discard", role: .cancel){}
                } message: {
                    Text("The watch is not connected with iPhone app.")
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
        session.sendMessage(["status": "started"])
    }
    
    func stopTimer() {
        timerRunning = false
        session.sendMessage(["status": "stopped"])
    }
    
    func saveData() {
        session.refresh()
        if (session.reachable){
            // Get the current date and time
            let now = Date()
            // Create an instance of DateFormatter
            let formatter = DateFormatter()
            // Set the date format
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            // Convert the date to a string
            let dateString = formatter.string(from: now)
            // Reflesh session to get updated status
            // Send message to phone
            session.sendMessage(["data": "\(dateString),\(timeElapsed)"])
            // Reset time
            self.timeElapsed = 0
        }else{
            showAlert = true
        }
    }

}

#Preview {
    ContentView()
}
