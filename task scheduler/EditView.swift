import SwiftUI
//backColor
//listColor
//textColor
struct EditView: View {
    @Environment(\.presentationMode) var presentMode
    @ObservedObject var elements: ScheduleItems
    let editingItem: ScheduleItem
    @State private var name: String
    @State private var date: Date
    @State private var time: Date
    @FocusState private var  isNameFocused: Bool
    init(elements: ScheduleItems, editingItem: ScheduleItem){
        self.elements = elements
        self.editingItem = editingItem
        _name = State(initialValue: editingItem.name)
        _date = State(initialValue: editingItem.dateExpiring)
        _time = State(initialValue: editingItem.dateExpiring)
    }
    var body: some View {
        NavigationView{
            ZStack{
                backColor.ignoresSafeArea(.all)
                Form {
                    TextField("Название", text: $name)
                        .padding(.vertical, 12)
                        .frame(minHeight: 55)
                        .contentShape(Rectangle())
                        .focused($isNameFocused)
                        .listRowBackground(listColor)
                    DatePicker("Дата", selection: $date, displayedComponents: .date)
                        .padding(.vertical, 8)
                        .listRowBackground(listColor)
                    DatePicker("Время", selection: $time, displayedComponents: .hourAndMinute)
                        .padding(.vertical, 8)
                        .listRowBackground(listColor)
                }
                .onAppear(perform: {
                    isNameFocused = true
                })
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Edit")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        if let index = elements.items.firstIndex(where: { $0.id == editingItem.id }) {
                            let calendar = Calendar.current
                            let finalDate = calendar.date(
                                bySettingHour: calendar.component(.hour, from: time),
                                minute: calendar.component(.minute, from: time),
                                second: 0,
                                of: date
                            ) ?? Date.now
                            let oldItem = elements.items[index]
                            elements.cancelNotifications(for: oldItem)
                            elements.items[index].name = name
                            elements.items[index].dateExpiring = finalDate
                            elements.items[index].isExpired = finalDate <= Date.now
                            if !elements.items[index].isDone && finalDate > Date.now {
                                elements.scheduleExpiryNotification(for: elements.items[index])
                                elements.scheduleReminders(for: elements.items[index])
                            }
                        }
                        presentMode.wrappedValue.dismiss()
                    }
                )
                
            }
        }
        
    }
}
#Preview {
    let test = ScheduleItems()
    let testItem = ScheduleItem(name: "Тест", dateExpiring: Date(), isExpired: false, isDone: false)
    EditView(elements: test, editingItem: testItem)
}
