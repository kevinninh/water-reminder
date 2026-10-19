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

class NotificationManger {
    
}

struct ContentView: View {
    @State private var remindersEnabled = false
    @State private var selectedInterval = 30
    var body: some View {
        VStack {
            Image(systemName: "drop.fill")
            Text(remindersEnabled ? "Reminders enabled" : "Reminders disabled")
            Text("I love Hoshimachi Suisei!!!!!")
                .foregroundStyle(.blue)
            Text("I also love Oozora Subaru!!!!")
                .background(.green)
            Button("Sakura Miko!!") {
                sakuraMiko()
            }
            .foregroundStyle(.pink)
            Button{
                remindersEnabled.toggle()
            }   label: {
                Text("enable reminders")
            }
            .padding()//why are buttons able to drop the parameters and let actions and labels go belowo them? is swift indent based like python as well?
            .background(.pink)
            .clipShape(.rect(cornerRadius: 10))
            Picker("Times", selection: $selectedInterval){
                Text("15 min").tag(15)
                Text("30 min").tag(30)
                Text("45 min").tag(45)
                Text("60 min").tag(60)
            }
            Text("\(selectedInterval)")
                .font(.largeTitle) //why are functions able to be called w/o a ()?
            UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
                    if let error = error{
                        print("Permission error: \(error)")
                        return
                    }
                    print("Permission granted: \(granted)")
                }
            Button("Test Notification"){
                
            }
        }
    }
}

#Preview {
    ContentView()
}
