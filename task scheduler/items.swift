import Foundation
import SwiftUI
import Combine
import UserNotifications
struct ScheduleItem: Identifiable, Codable{
    var id = UUID()
    var name: String
    var dateExpiring: Date
    var isExpired: Bool
    var isDone: Bool
}
class ScheduleItems: ObservableObject{
    @Published var refreshTrigger = false
    private var timerCancellable: AnyCancellable?
    @Published var items = [ScheduleItem](){
        didSet {
            let encoder = JSONEncoder()
            if let encoded = try? encoder.encode(items) {
                UserDefaults.standard.set(encoded, forKey: "Items")
            }
        }
    }
    init() {
        if let items = UserDefaults.standard.data(forKey: "Items") {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ScheduleItem].self, from: items) {
                self.items = decoded
            }
        }
    }
    func startTimer() {
        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.refreshTrigger.toggle()
            }
    }
    func stopTimer() {
        timerCancellable?.cancel()
    }
    func loadTestData() {
        items = [
            ScheduleItem(
                id: UUID(),
                name: "⌛ Истекает через минуту",
                dateExpiring: Date.now.addingTimeInterval(60),
                isExpired: false,
                isDone: false
            ),
            ScheduleItem(
                id: UUID(),
                name: "✅ Выполнено (успешно)",
                dateExpiring: Date.now.addingTimeInterval(7200),
                isExpired: false,
                isDone: true
            ),
            ScheduleItem(
                id: UUID(),
                name: "⚠️ Просрочено (красный круг)",
                dateExpiring: Date.now.addingTimeInterval(-1800),
                isExpired: true,
                isDone: false
            ),
            ScheduleItem(
                id: UUID(),
                name: "🟢 Активная задача (3 часа)",
                dateExpiring: Date.now.addingTimeInterval(10800),
                isExpired: false,
                isDone: false
            ),
            ScheduleItem(
                id: UUID(),
                name: "📝 Задача на завтра",
                dateExpiring: Date.now.addingTimeInterval(86400),
                isExpired: false,
                isDone: false
            ),
            ScheduleItem(
                id: UUID(),
                name: "🎯 Дедвелайн через 10 сек",
                dateExpiring: Date.now.addingTimeInterval(10),
                isExpired: false,
                isDone: false
            )
        ]
    }
    func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            guard granted else {
                print("Not allowed")
                return
            }
            print("Access granted")
        }
    }
    func scheduleExpiryNotification(for item: ScheduleItem){
        guard !item.isDone else {return}
        guard item.dateExpiring > Date.now else {return}
        let content = UNMutableNotificationContent()
        content.title = "Task is expired!!!"
        content.body = " Task \"\(item.name)\" is expired "
        content.sound = UNNotificationSound(named: UNNotificationSoundName("not_sound.caf"))
        content.badge = 1
        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dateExpiring)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        let request = UNNotificationRequest(identifier: "expiry_\(item.id.uuidString)", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }
    func scheduleReminders(for item: ScheduleItem){
        guard !item.isDone else {return}
        guard item.dateExpiring > Date.now else {return}
        let timeRemaining = item.dateExpiring.timeIntervalSinceNow
        let hoursRemaining = timeRemaining/3600
        if hoursRemaining <= 24 && hoursRemaining >= 1{
            let hoursToDeadline = Int(hoursRemaining)
            for hour in 1...hoursToDeadline{
                let reminderDate = item.dateExpiring.addingTimeInterval(-Double(hour * 3600))
                guard reminderDate > Date.now else {continue}
                let content = UNMutableNotificationContent()
                if hour == 1{
                    content.title = "Deadline after 1 hour!!!"
                    content.body = "Task \"\(item.name)\" is expiring after 1 hour "
                }
                else {
                    content.title = "Reminder"
                    content.body = "Task \"\(item.name)\" is expiring after \(hour) hours"
                }
                content.sound = UNNotificationSound(named: UNNotificationSoundName("not_sound.caf"))
                let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dateExpiring)
                let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
                let request = UNNotificationRequest(identifier: "expiry_\(item.id.uuidString)", content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request)
            }
        }
    }
    func cancelNotifications(for item: ScheduleItem){
        let expiryID = "expiry_\(item.id.uuidString)"
        let reminderIDs = (1...24).map{
            "reminder_\(item.id.uuidString)_\($0)"
        }
        let allIDs = [expiryID] + reminderIDs
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIDs)
    }
    func rescheduleAllNotifications() {
        let allIds = items.flatMap { item in
            ["expiry_\(item.id.uuidString)"] + (1...24).map { "reminder_\(item.id.uuidString)_\($0)" }
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: allIds)
        for item in items where !item.isDone && item.dateExpiring > Date.now {
            scheduleExpiryNotification(for: item)
            scheduleReminders(for: item)
        }
    }
    func addItemWithNotifications(_ item: ScheduleItem) {
        items.append(item)
        if !item.isDone && item.dateExpiring > Date.now {
            scheduleExpiryNotification(for: item)
            scheduleReminders(for: item)
        }
    }
    func removeItemWithNotifications(at offsets: IndexSet) {
        for index in offsets {
            let item = items[index]
            cancelNotifications(for: item)
        }
        items.remove(atOffsets: offsets)
    }
    func toggleDoneWithNotifications(for item: ScheduleItem) {
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index].isDone.toggle()
            
            if items[index].isDone {
                cancelNotifications(for: items[index])
            } else if items[index].dateExpiring > Date.now {
                scheduleExpiryNotification(for: items[index])
                scheduleReminders(for: items[index])
            }
        }
    }
}
