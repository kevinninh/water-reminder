import SwiftUI
import UserNotifications

// Keep this in ContentView.swift, or move it into NotificationManager.swift.
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    private let reminderID = "water-reminder"
    private let center = UNUserNotificationCenter.current()

    // Ask only when needed. A denied permission must be changed in Settings.
    func ensureAuthorization() async throws -> Bool {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .authorized, .provisional, .ephemeral:
            return true
        case .notDetermined:
            return try await center.requestAuthorization(options: [.alert, .sound])
        case .denied:
            return false
        @unknown default:
            return false
        }
    }

    func scheduleNotification(intervalMinutes: Int) async throws {
        // Repeating time-interval triggers must be at least 60 seconds.
        guard intervalMinutes >= 1 else { throw ReminderError.invalidInterval }

        let content = UNMutableNotificationContent()
        content.title = "Drink water"
        content.body = "Time for a water break."
        content.sound = .default

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(intervalMinutes * 60),
            repeats: true
        )
        // Reusing this identifier replaces the existing pending reminder.
        let request = UNNotificationRequest(
            identifier: reminderID,
            content: content,
            trigger: trigger
        )
        try await center.add(request)
    }

    func cancelNotifications() {
        center.removePendingNotificationRequests(withIdentifiers: [reminderID])
    }

    func scheduledIntervalMinutes() async -> Int? {
        let requests = await center.pendingNotificationRequests()
        guard let request = requests.first(where: { $0.identifier == reminderID }),
              let trigger = request.trigger as? UNTimeIntervalNotificationTrigger,
              trigger.repeats else { return nil }
        return Int(trigger.timeInterval / 60)
    }

    func isAuthorized() async -> Bool {
        let status = await center.notificationSettings().authorizationStatus
        switch status {
        case .authorized, .provisional, .ephemeral: return true
        default: return false
        }
    }

    enum ReminderError: LocalizedError {
        case invalidInterval
        var errorDescription: String? { "Choose an interval of at least one minute." }
    }
}

struct ContentView: View {
    @Environment(\.scenePhase) private var scenePhase
    @AppStorage("notificationInterval") private var notificationInterval = 30
    @State private var remindersEnabled = false
    @State private var isBusy = false
    @State private var errorMessage: String?

    var body: some View {
        VStack(spacing: 22) {
            Image(systemName: "drop.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)

            Text("WaterReminder")
                .font(.largeTitle.bold())

            Text(remindersEnabled ? "Reminders are on" : "Reminders are off")
                .foregroundStyle(.secondary)

            Picker("Remind me every", selection: $notificationInterval) {
                Text("15 minutes").tag(15)
                Text("30 minutes").tag(30)
                Text("45 minutes").tag(45)
                Text("60 minutes").tag(60)
            }
            .pickerStyle(.menu)
            .disabled(isBusy)
            .onChange(of: notificationInterval) { _, newValue in
                guard remindersEnabled else { return }
                Task { await reschedule(to: newValue) }
            }

            Button {
                Task { await toggleReminders() }
            } label: {
                Text(remindersEnabled ? "Disable reminders" : "Enable reminders")
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .buttonStyle(.borderedProminent)
            .disabled(isBusy)

            if isBusy {
                ProgressView()
            }
        }
        .padding()
        .task { await refreshState() }
        .onChange(of: scenePhase) { _, phase in
            if phase == .active {
                Task { await refreshState() }
            }
        }
        .alert("Notification issue", isPresented: Binding(
            get: { errorMessage != nil },
            set: { if !$0 { errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { errorMessage = nil }
        } message: {
            Text(errorMessage ?? "Unknown error")
        }
    }

    @MainActor
    private func toggleReminders() async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        if remindersEnabled {
            NotificationManager.shared.cancelNotifications()
            remindersEnabled = false
            return
        }

        do {
            guard try await NotificationManager.shared.ensureAuthorization() else {
                errorMessage = "Notifications are disabled. Allow notifications for WaterReminder in the iPhone Settings app."
                return
            }
            try await NotificationManager.shared.scheduleNotification(intervalMinutes: notificationInterval)
            remindersEnabled = true
        } catch {
            errorMessage = error.localizedDescription
            remindersEnabled = false
        }
    }

    @MainActor
    private func reschedule(to minutes: Int) async {
        guard !isBusy else { return }
        isBusy = true
        defer { isBusy = false }

        do {
            guard await NotificationManager.shared.isAuthorized() else {
                remindersEnabled = false
                errorMessage = "Notification permission is no longer available. Check iPhone Settings."
                return
            }
            try await NotificationManager.shared.scheduleNotification(intervalMinutes: minutes)
        } catch {
            errorMessage = error.localizedDescription
            let previousInterval = await NotificationManager.shared.scheduledIntervalMinutes()
            if let previousInterval {
                notificationInterval = previousInterval
            } else {
                remindersEnabled = false
            }
        }
    }

    @MainActor
    private func refreshState() async {
        guard !isBusy else { return }
        let manager = NotificationManager.shared
        let authorized = await manager.isAuthorized()
        let scheduledMinutes = await manager.scheduledIntervalMinutes()
        remindersEnabled = authorized && scheduledMinutes != nil
        if let scheduledMinutes, remindersEnabled, [15, 30, 45, 60].contains(scheduledMinutes) {
            notificationInterval = scheduledMinutes
        }
    }
}

#Preview {
    ContentView()
}
