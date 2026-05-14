import Foundation
import SwiftUI
import Combine
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
}
