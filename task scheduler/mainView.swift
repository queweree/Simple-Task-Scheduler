import SwiftUI
import UserNotifications
import Foundation
let backColor = LinearGradient(
    colors: [
        Color(red: 0.85, green: 0.70, blue: 0.55),
        Color(red: 0.80, green: 0.60, blue: 0.45)
    ],
    startPoint: .top,
    endPoint: .bottom
)
let listColor = Color.black.opacity(0.3)
let textColor = Color.black.opacity(0.25)
struct MainView: View {
    @State private var showingAddScreen = false
    @State private var editingItem: ScheduleItem? = nil
    @ObservedObject var elements = ScheduleItems()
    var sortedElements: [ScheduleItem] {elements.items.sorted(by: {
        return $0.dateExpiring < $1.dateExpiring
    })}
    var body: some View {
        NavigationView{
            ZStack{
                backColor.ignoresSafeArea(.all)
                VStack{
                    if elements.items.isEmpty{
                        VStack{
                            Image(systemName:"tray.fill")
                                .font(.system(size: 124))
                                .opacity(0.4)
                            Text("No tasks")
                                .font(.system(size: 24))
                                .foregroundColor(textColor)
                            Text("Press + to add")
                                .foregroundColor(textColor)
                                .font (.system(size: 24))
                        }
                    }
                    else{
                        List{
                            ForEach(sortedElements){ el in
                                HStack{
                                    VStack(alignment: .leading){
                                        Text(el.name)
                                            .font(.caption)
                                            .foregroundColor(.black.opacity(0.7))
                                            .strikethrough(el.isDone)
                                        Text("\(el.dateExpiring, format: .dateTime.hour().minute().day().month())")
                                    }
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        editingItem = el
                                    }
                                    Spacer()
                                    if el.isDone{
                                        Image(systemName: "checkmark.circle.fill")
                                            .foregroundColor(.green)
                                            .contentShape(Rectangle())
                                            .onTapGesture{
                                                elements.toggleDoneWithNotifications(for: el)
                                            }
                                    }
                                    else if countRemainingTime(for: el) <= 0{
                                        Image(systemName: "circle.fill")
                                            .foregroundColor(.red)
                                            .contentShape(Rectangle())
                                            .onTapGesture{
                                                elements.toggleDoneWithNotifications(for: el)
                                            }
                                    }
                                    else {
                                        Image(systemName: "circle")
                                            .foregroundColor(.gray)
                                            .contentShape(Rectangle())
                                            .onTapGesture{
                                                elements.toggleDoneWithNotifications(for: el)
                                            }
                                        
                                    }
                                }
                            }  .onDelete { offsets in
                                deleteItem(at: offsets)
                            }
                            .listRowBackground(listColor)
                        }
                        .scrollContentBackground(.hidden)
                    }
                }
                .navigationBarTitle("My tasks")
                .navigationBarTitleDisplayMode(.large)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button(action: {
                            showingAddScreen = true
                        }) {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingAddScreen) {
                    AddView(elements: elements)
                }
                .sheet(item: $editingItem) { item in
                    EditView(elements: elements, editingItem: item)
                }
            }
        }
        .onAppear{
            //elements.loadTestData()
            elements.requestNotificationPermission()
            elements.startTimer()
            elements.rescheduleAllNotifications()
        }
        .onDisappear {
            elements.stopTimer()
        }
    }
    func countRemainingTime(for item: ScheduleItem) ->TimeInterval{
        return item.dateExpiring.timeIntervalSinceNow
    }
    func deleteItem(at offsets: IndexSet){
        elements.removeItemWithNotifications(at: offsets)
    }
    
}

#Preview {
    MainView()
}
