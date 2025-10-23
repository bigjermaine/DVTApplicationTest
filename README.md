DVTApplicationTest
A lightweight iOS application built with SwiftUI, demonstrating the MVVM (Model–View–ViewModel) architectural pattern and showcasing best practices in reactive data binding, persistence, and Swift concurrency — all using native Apple frameworks with no third-party dependencies.

🧩 Project Structure

<img width="780" height="761" alt="Screenshot 2025-10-23 at 10 26 57" src="https://github.com/user-attachments/assets/eb3c4b0c-7711-4cd4-b7aa-294e32229671" />




🏗️ Overview
DVTApplicationTest emphasizes clean architecture and modern SwiftUI techniques for iOS 16+. It integrates:
* UserDefaults — for quick, transient data (e.g., favorite weather locations)
* Core Data — for structured, persistent storage of entities
This project is ideal for demonstrating real-world SwiftUI development, local data persistence, and reactive UI updates.

🚀 Key Features
MVVM Architecture
A clean separation of concerns:
* Model — Defines entities and Core Data schemas.
* ViewModel — Manages app logic, persistence, and state updates.
* View — Declarative SwiftUI UI bound to observable state.
SwiftUI Interface
* Fully built with SwiftUI components (Lists, Forms, Navigation).
* Uses NavigationStack, async/await, and @Observable for real-time reactivity.
Local Data Storage
* UserDefaults for simple key-value persistence (e.g., favorites, settings).
* Core Data for structured data and entity relationship management.
Modern iOS 17 APIs
* Swift Concurrency (async/await)
* @Observable for dynamic UI binding.
* NavigationStack for native, declarative navigation.
No External SDKs
* 100% native Swift and Apple frameworks
* No third-party dependencies — ensuring maintainability, simplicity, and portability.
Unit Tests
* Includes tests for WeatherStateStorageManager to validate data persistence and retrieval logic.

🔄 Architecture Diagram — Data Flow
1. View initializes and binds to a ViewModel instance.
2. ViewModel fetches or saves data via Core Data or UserDefaults.
3. User actions trigger logic in the ViewModel, updating observable state.
4. SwiftUI automatically reflects state changes in the View.

🎧 Additional Features
* Haptic feedback integration for tactile interactions
* Custom sound effects managed through SoundManager
* Dynamic background switching (e.g., forest or sea themes)

⚙️ Technical Requirements
Tool	Version
iOS	16.0+
Xcode	15.0+
Swift	5.9+
Dependencies	None
🧱 Installation
1. Clone the repository    git clone https://github.com/bigjermaine/DVTApplicationTest.git
2.   Open the project
3. 
    * Launch DVTApplicationTest.xcodeproj in Xcode
    * Select an iOS 17+ device or simulator
4. Build & Run
    * Press ⌘ + R to compile and run the app
    * Core Data permissions are automatically handled in the simulator
5. Optional: Core Data Setup
    * Use Editor → Create NSManagedObject Subclass for new entities
    * Ensure the persistent container is initialized in App.swift

🌿 Branching Strategy
The repository uses three branches to mirror real-world CI/CD workflows:
Branch	Purpose
dev	Active development and feature experimentation
staging	Pre-production QA and integration testing
main	Stable, production-ready release
This setup demonstrates collaborative version control and supports automated testing or continuous integration pipelines.

🧭 Usage
1. Launch the app and grant Location Access
2. Switch simulator location to test weather data updates
3. Tap the ❤️ icon to add a city to favorites (stored via UserDefaults)
4. Modify Settings to toggle sound, haptics, and background themes
5. View offline weather data when network access is unavailable

🧪 Testing
To run tests:

⌘ + U
Includes unit tests for:
* Data persistence (Core Data + UserDefaults)
* ViewModel logic and state transitions

📚 Learning Outcomes
DVTApplicationTest demonstrates:
* Implementing MVVM cleanly in SwiftUI
* Integrating Core Data and UserDefaults
* Handling asynchronous data flows with async/await
* Managing state reactively with SwiftUI bindings
* Structuring an iOS app for scalability and maintainability
