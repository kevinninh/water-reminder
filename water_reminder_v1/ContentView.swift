//
//  ContentView.swift
//  water_reminder_v1
//
//  Created by Kevin Ninh on 10/17/26.
//

import SwiftUI
import UserNotifications

func sakuraMiko() {
    print("Sakura Miko!!")
}


class NotificationManager {
    static let shared = NotificationManager() //singleton design pattern
    
    private init(){
    }
    
    func scheduleNotification(){
        let content = UNMutableNotificationContent()
        content.title = "Drink water"
        content.body = "here to be here lol"
        content.sound = UNNotificationSound.default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        
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
            /*Text(remindersEnabled ? "Reminders enabled" : "Reminders disabled")
            Text("I love Hoshimachi Suisei!!!!!")
                .foregroundStyle(.blue)
            Text("I also love Oozora Subaru!!!!")
                .background(.green)
            Button("Sakura Miko!!") {
                sakuraMiko()
            }
            .foregroundStyle(.pink)*/
            Button{
                remindersEnabled.toggle()
                if remindersEnabled{
                    NotificationManager.shared.scheduleNotification()
                }
                else{
                    NotificationManager.shared.cancelNotifications()
                }
            }   label: {
                Text("enable reminders")
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
            Text("\(selectedInterval)")
                .font(.largeTitle)
            Button("Request Notification Auth"){
                print("Noti auth button pressed")
                NotificationManager.shared.requestAuthorization()
            }
            Button("Schedule Notification"){
                print("schedule button pressed")
                NotificationManager.shared.scheduleNotification()
            }
        }
    }
}

#Preview {
    ContentView()
}

/*
 Questions:
 why are functions able to be called w/o a ()?
 why are buttons able to drop the parameters and let actions and labels go belowo them? is swiftindent based like python as well? Its kinda insane that I can create an object, and I can also adjust the object just by putting the adjustments in the next line, rather than needing brackets
 */
