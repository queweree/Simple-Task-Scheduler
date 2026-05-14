import SwiftUI
//backColor
//listColor
//textColor
struct AddView: View {
    @Environment(\.presentationMode) var presentMode
    @ObservedObject var elements: ScheduleItems
    @State private var name: String = ""
    @State private var date: Date = Date()
    @State private var time: Date = Date()
    @FocusState private var  isNameFocused: Bool
    var isFormValid: Bool {
        return !name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    var body: some View {
        NavigationView{
            ZStack{
                backColor.ignoresSafeArea(.all)
                Form {
                    TextField("Name", text: $name)
                        .padding(.vertical, 12)
                        .frame(minHeight: 55)
                        .contentShape(Rectangle())
                        .focused($isNameFocused)
                        .listRowBackground(listColor)
                    DatePicker("Date", selection: $date, displayedComponents: .date)
                        .padding(.vertical, 8)
                        .listRowBackground(listColor)
                    DatePicker("Time", selection: $time, displayedComponents: .hourAndMinute)
                        .padding(.vertical, 8)
                        .listRowBackground(listColor)
                }
                .onAppear(perform: {
                    isNameFocused = true
                })
                .scrollContentBackground(.hidden)
                .navigationBarTitle("Add")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(
                    leading: Button("Cancel") {
                        presentMode.wrappedValue.dismiss()
                    },
                    trailing: Button("Save") {
                        let calendar = Calendar.current
                        let finalDate = calendar.date(
                            bySettingHour: calendar.component(.hour, from: time),
                            minute: calendar.component(.minute, from: time),
                            second: 0,
                            of: date
                        ) ?? Date.now
                        
                        let newItem = ScheduleItem(
                            name: name,
                            dateExpiring: finalDate,
                            isExpired: false,
                            isDone: false
                        )
                        elements.items.append(newItem)
                        presentMode.wrappedValue.dismiss()
                    }.disabled(!isFormValid)
                )
                
            }
        }
        
    }
}
#Preview {
    AddView(elements: ScheduleItems())
}
