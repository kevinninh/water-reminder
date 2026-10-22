//
//  ContentView.swift
//  water_reminder_v1
//
//  Created by Kevin Ninh on 10/17/26.
//

import SwiftUI
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager() //singleton design pattern
    
    private init(){
    }
    
    func scheduleNotification(interval: Int, shouldRepeat: Bool){
        let content = UNMutableNotificationContent()
        content.title = "Drink water"
        content.body = "here to be here lol"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(interval*60), repeats: shouldRepeat)
        
        let request = UNNotificationRequest(identifier: "example notification",content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    
    func requestAuthorization(){
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                if let error = error{
                    print("Permission error: \(error)")
                    return
                }
                print("Permission granted: \(granted)")
            }
    }
    
    func cancelNotifications(){
        UNUserNotificationCenter.current()
            .removePendingNotificationRequests(withIdentifiers: ["example notification"])
    }
}

struct ContentView: View {
    @State private var remindersEnabled = false
    @State private var selectedInterval = 30
    var body: some View {
        VStack {
            Image(systemName: "drop.fill")
            Text("\(remindersEnabled)")
            Button{
                remindersEnabled.toggle()
                if remindersEnabled{
                    NotificationManager.shared.scheduleNotification(interval: selectedInterval, shouldRepeat: remindersEnabled)
                }
                else{
                    NotificationManager.shared.cancelNotifications()
                }
            }   label: {
                Text(remindersEnabled ? "disable reminders" : "enable reminders")
            }
            .padding()
            .background(.pink)
            .clipShape(.rect(cornerRadius: 10))
            Picker("Times", selection: $selectedInterval){
                Text("15 min").tag(15)
                Text("30 min").tag(30)
                Text("45 min").tag(45)
                Text("60 min").tag(60)
            }
            .onChange(of: selectedInterval){
                if remindersEnabled{
                    NotificationManager.shared.scheduleNotification(interval: selectedInterval, shouldRepeat: remindersEnabled)
                }
            }
        
            Text("\(selectedInterval)")
                .font(.largeTitle)
            Button("Request Notification Auth"){
                print("Noti auth button pressed")
                NotificationManager.shared.requestAuthorization()
            }
            Button("Schedule Notification"){
                print("schedule button pressed")
                NotificationManager.shared.scheduleNotification(interval: selectedInterval, shouldRepeat: remindersEnabled)
            }
        }
    }
}

#Preview {
    ContentView()
}
