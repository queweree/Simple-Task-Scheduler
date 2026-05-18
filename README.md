# Task Scheduler 📱⏰

[![Swift](https://img.shields.io/badge/Swift-5.9-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg)](https://developer.apple.com/ios/)

A beautiful and functional task scheduler iOS app with local notifications that remind you about upcoming deadlines — even when the app is closed.

---

## 📸 Screenshots

<img src="Снимок экрана — 2026-05-18 в 20.11.18.png" width="300" alt="Notification Screenshot"/>

*System notification showing a task expiration alert*

---

## ✨ Features

- ✅ **Create, Edit & Delete Tasks** — Simple and intuitive task management
- ⏰ **Smart Notifications** — Get alerted before deadlines
- 🔔 **Custom Sound** — Distinctive notification sound from the game *"Fear to Fathom"*
- 📅 **Date & Time Picker** — Choose exact deadline for each task
- 🎨 **Beautiful UI** — Warm caramel gradient background with semi-transparent list styling
- 🔄 **Real-time Countdown** — Remaining time updates every second
- 💾 **Persistent Storage** — Tasks are saved locally using UserDefaults
- 📱 **Background Notifications** — Alerts work even when the app is closed

---

## ⏰ Notification System

The app features an intelligent notification system:

| Scenario | Notification Trigger |
|----------|---------------------|
| **≤ 24 hours remaining** | Hourly reminders |
| **1 hour remaining** | Urgent "Deadline after 1 hour!" alert |
| **Deadline reached** | "Task is expired" notification |
| **Task completed** | All pending notifications are cancelled |

---

## 🎵 Custom Sound

The notification sound is a custom `.caf` audio file taken from the psychological horror game **"Fear to Fathom"** — adding a unique and eerie vibe to deadline reminders.

---

## 🛠️ Technical Details

- **Framework:** SwiftUI + UIKit (for notifications)
- **Local Notifications:** `UserNotifications` framework
- **Data Persistence:** `UserDefaults` with `Codable`
- **Timer Mechanism:** `Timer.publisher` with Combine
- **Minimum iOS Version:** 15.0

---

## 📁 Project Structure

```
task_scheduler/
├── Models/
│   └── items.swift           # ScheduleItem model + ScheduleItems ViewModel
├── Views/
│   ├── mainView.swift        # Main task list screen
│   ├── AddView.swift         # Add new task screen
│   └── EditView.swift        # Edit existing task screen
├── App/
│   ├── task_schdulerApp.swift # App entry point
│   └── AppDelegate.swift      # Notification delegate
└── Assets/
    └── not_sound.caf          # Custom notification sound
```

---

## 🚀 How to Run

1. Clone the repository:
```bash
git clone https://github.com/yourusername/task-scheduler.git
cd task-scheduler
```

2. Open `task_scheduler.xcodeproj` in Xcode

3. Select your target device/simulator (iOS 15+)

4. Press `Cmd + R` to build and run

---

## 📲 Usage

1. **Add a task:** Tap the `+` button → Enter name → Select date & time → Save
2. **Mark as done:** Tap the circle icon next to a task
3. **Edit a task:** Tap on the task text
4. **Delete a task:** Swipe left on the task row
5. **Grant permissions:** Allow notifications when prompted on first launch

---

## 🔔 Notification Permissions

The app will request notification permissions on first launch. You need to allow notifications for the reminder system to work properly. You can change permissions later in **Settings → Notifications → task_scheduler**

---

## 🧪 Testing Notifications

To test notifications without waiting hours:

1. Add a task with deadline 1-2 minutes from now
2. Close the app (swipe up from app switcher)
3. Wait for the notification to arrive

---

## ⚠️ Known Limitations

- Notifications won't appear if the user has disabled them in system settings
- Custom sound file must be in `.caf` format with PCM/IMA4 encoding
- Hourly reminders only work for deadlines within 24 hours

---

## 🤝 Contributing

Pull requests are welcome! For major changes, please open an issue first to discuss what you'd like to change.


## 🙏 Acknowledgments

- Sound effect from *Fear to Fathom* (used for personal project purposes)
- SwiftUI and Apple's Human Interface Guidelines
