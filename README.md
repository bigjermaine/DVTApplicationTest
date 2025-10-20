DVTApplicationTest
A lightweight iOS application built with SwiftUI to demonstrate the MVVM (Model–View–ViewModel) architectural pattern. It showcases best practices in reactive data binding, persistence, and Swift concurrency using native Apple frameworks.

no third-party dependencies.

Overview
This project emphasizes clean architecture and modern SwiftUI techniques for iOS 17 and above. It integrates UserDefaults for quick, transient data (e.g favorites) and Core Data for structured, persistent storage of entities.

Features
* MVVM Architecture — Clear separation of concerns between:
    * Model: Defines entities and Core Data schemas.
    * ViewModel: Manages app logic, persistence, and state updates.
    * View: Declarative SwiftUI UI bound to observable state.
* SwiftUI Interface
    * Built entirely with SwiftUI components (lists, forms, navigation).
    * Uses NavigationStack, async/await, and @Observable for reactive updates.
* Local Data Storage
    * UserDefaults: For simple key-value persistence such as favorite weather states.
    * Core Data: For storing structured data and managing entity relationships.
* Modern iOS 17 APIs
    * Swift Concurrency (async/await)
    * New @Observable property wrapper for real-time UI updates.
    * Native navigation with NavigationStack.
* No External SDKs
    * 100% native Swift and Apple frameworks for maximum maintainability and portability.
* Unit Tests
    * Includes tests for WeatherStateStorageManager to validate data persistence and retrieval logic.

Architecture Diagram
Data Flow:
1. View initializes and binds to a ViewModel instance.
2. ViewModel fetches or saves data through Core Data or UserDefaults.
3. User interactions trigger state changes in ViewModel.
4. Updated data automatically reflects in the View via SwiftUI bindings.

Technical Requirements
Tool	Version
iOS	17.0+
Xcode	15.0+
Swift	5.9+
No additional frameworks or SDKs are required.

Installation
1. Clone the repository    git clone https://github.com/bigjermaine/DVTApplicationTest.git
2. Open the project   
3. 
    * Launch DVTApplicationTest.xcodeproj in Xcode.
    * Select an iOS 17+ device or simulator.
4. Build & Run
    * Press ⌘ + R to compile and run the app.
    * Core Data permissions are automatically handled in the simulator.
5. Core Data Setup (optional)
    * Use Editor → Create NSManagedObject Subclass for any new entities.
    * Ensure the persistent container is initialized in App.swift.
  
Branching Strategy
* Uses three Git branches to demonstrate real-world branching workflows:
    * dev → Active development branch for ongoing features and experiments.
    * staging → Pre-production branch for QA and integration testing.
    * main → Stable, production-ready code.
* This setup reflects best practices for collaborative version control and continuous integration.

Usage
1. Launch the app and allow Location Access.
2. Switch simulator locations to observe weather data updates.
3. Tap the heart icon to add a location to favorites (stored via UserDefaults).
4. Modify settings to toggle sound, haptics, and background options.
5. View offline-stored weather data when network access is unavailable


<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2025-10-20 at 16 12 28" src="https://github.com/user-attachments/assets/e4ed0d61-220b-46a6-bc16-b4e36cb7e2e5" />

<img width="1206" height="2622" alt="Simulator Screenshot - iPhone 17 - 2025-10-20 at 16 12 36" src="https://github.com/user-attachments/assets/9e49b536-ce4d-497a-a203-77fb1652515c" />

