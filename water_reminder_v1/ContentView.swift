//
//  ContentView.swift
//  water_reminder_v1
//
//  Created by Kevin Ninh on 10/17/26.
//

import SwiftUI

func sakuraMiko() {
    print("Sakura Miko!!")
}

struct ContentView: View {
    @State private var remindersEnabled = false
    var body: some View {
        VStack {
            Image(systemName: "drop.fill")
            Text(remindersEnabled ? "Reminders enabled" : "Reminders disabled")
            Text("I love Hoshimachi Suisei!!!!!")
            Text("I also love Oozora Subaru.")
                .background(.green)
            Button("Sakura Miko!!") {
                sakuraMiko()
            }
            Button{
                remindersEnabled.toggle()
            }   label: {
                Text("enable reminders")
            }
            .padding()
            .frame(width: 250, height: 60)
            .background(.pink)
            .clipShape(.rect(cornerRadius: 20))
        }
    }
}

#Preview {
    ContentView()
}
