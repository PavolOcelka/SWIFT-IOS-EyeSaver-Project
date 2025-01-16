//
//  ContentView.swift
//  EyeSaver
//
//  Created by Pavol Ocelka on 16/01/2025.
//

import SwiftUI
import UserNotifications

struct ContentView: View {
    @State private var timeRemaining: TimeInterval = 5
    @State private var timer: Timer?
    @State private var isRunning = false
    @State private var isTimerFinished = false
    @State private var opacity = 1.0
    @State private var isShowingAlert = false
    let notificationCenter = UNUserNotificationCenter.current()
    
    
    var body: some View {
        ZStack{
            Color.fromRGB(red: 124, green: 68, blue: 79)
                .ignoresSafeArea()
            VStack{
                HStack{
                    Spacer()
                    VStack(alignment: .trailing, spacing: 0){
                        Text(formattedTime())
                            .foregroundStyle(.secondary)
                            .font(.system(size: 50).bold())
                        
                        HStack{
                            Button(action: {
                                timeRemaining += 60
                            }) {
                                Image(systemName: "plus")
                            }
                            Button(action: {
                                if timeRemaining > 60 {
                                    timeRemaining -= 60
                                }
                            }) {
                                Image(systemName: "minus")
                            }
                            
                        }
                        
                        Button(action: {
                            Task {
                                do {
                                    try await notificationCenter.requestAuthorization(options: [.alert, .badge, .sound])
                                } catch {
                                    print("Request authorization error")
                                }
                            }
                        }) {
                            Image(systemName: "bell")
                        }
                        .buttonStyle(.plain)
                        .padding(.top, 10)
                    }
                }
                .padding()
                Spacer()
            }
            VStack{
                ZStack{
                    Circle().fill(Color.white)
                        .frame(width: 200)
                    
                    if isTimerFinished {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 150)
                            .opacity(opacity)
                            .onAppear {
                                withAnimation(
                                    Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true)
                                ) {
                                    opacity = 0.3
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
                                    isTimerFinished = false
                                }
                            }
                    }
                    
                    Circle().fill(Color.black)
                        .frame(width: 100)
                }
                .padding()
                
                Button(action: {
                    isRunning.toggle()
                    if isRunning{
                        startTimer()
                        
                    } else{
                        stopTimer()
                    }
                }) {
                    Text(isRunning ? "Stop": "Start").font(.system(size: 25))
                        .foregroundStyle(!isRunning ? Color.fromRGB(red: 124, green: 68, blue: 79): Color(.red))
                        .frame(maxWidth: 150, minHeight: 50)
                }
                .background(.secondary)
                .clipShape(.capsule)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .alert("Eye Break", isPresented: $isShowingAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text("Take a break and let your eyes relax!")
        }
        .onAppear {
            requestNotificationPermission()
        }
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0{
                timeRemaining -= 1
            } else{
                isShowingAlert = true
                isTimerFinished = true
                stopTimer()
                scheduleNotification()
            }}
    }
    
    private func formattedTime() -> String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private func stopTimer() {
        isRunning = false
        timer?.invalidate()
        timeRemaining = 1500
    }
    
    private func scheduleNotification() {
        let content = UNMutableNotificationContent()
        content.title = "Timer Finished"
        content.body = "Take a break and let your eyes relax!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)
        
        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
    
    private func requestNotificationPermission() {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                if granted {
                    print("Notification permission granted")
                } else if let error = error {
                    print("Error requesting notification permission: \(error)")
                } else {
                    print("Permission denied")
                }
            }
        }
    }
}

extension Color {
    
    static func fromRGB(red: Double, green: Double, blue: Double) -> Color {
        
        let rgbRed = CGFloat(red/255)
        let rgbGreen = CGFloat(green/255)
        let rgbBlue = CGFloat(blue/255)
        
        let color = Color(red: rgbRed, green: rgbGreen, blue: rgbBlue)
        return color
    }
}

#Preview {
    ContentView()
}
