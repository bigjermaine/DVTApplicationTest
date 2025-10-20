DVTApplicationTest App

￼
A simple iOS app demonstrating the MVVM (Model-View-ViewModel) architecture using SwiftUI. This project uses UserDefaults for lightweight, ephemeral local storage and Core Data for persistent data management for storing app entities. No third-party SDKs or dependencies are used everything is built with native Apple frameworks.

Features
* MVVM Architecture: Clean separation of concerns with Models (data entities), Views (SwiftUI UI), and ViewModels (business logic and data binding).
* SwiftUI UI: Modern, declarative UI with lists, forms, and navigation.
* Local Storage:
    * UserDefaults: For simple key-value storage like favourite weather
    * Core Data: For relational data persistence (e.g., Todo items with attributes like title, completion status, and creation date).
* iOS 17+ Features: Leverages SwiftUI's improved navigation (e.g., NavigationStack), async/await for data operations, and @Observable for ViewModel reactivity.
* No External Dependencies: Pure Apple ecosystem—easy to build and maintain.
* Unit Tests: Basic tests for WeatherStateStorageManager
Architecture Overview
Model (M)
* Defines data structures (e.g., TodoItem entity in Core Data).
* Core Data model: Single entity Todo with attributes (id: UUID, title: String, isCompleted: Bool, createdAt: Date).
View (V)
* SwiftUI views: ContentView (main list), AddTodoView (form), TodoDetailView (edit).
* Binds to ViewModel using @StateObject and @ObservedObject.
ViewModel (VM)
* Handles logic: Fetching/saving from Core Data, updating UserDefaults.
* Uses @Observable (iOS 17+) for automatic UI updates.
* Async operations for Core Data (e.g., saveTodo() with await).
Data Flow
1. View loads → Binds to ViewModel.
2. ViewModel fetches data from Core Data → Exposes @Published arrays/observables.
3. User interacts → ViewModel updates Model (Core Data) or UserDefaults.
4. Changes propagate back to View via bindings.

Requirements
* iOS: 17.0 or later
* Xcode: 15.0 or later
* Swift: 5.9+
* Deployment Target: iOS 17.0
* No additional SDKs required.
Installation
1. Clone the Repo git clone https://github.com/yourusername/mvvm-swiftui-example.git ](https://github.com/bigjermaine/DVTApplicationTest
2. Open in Xcode:
    * Launch MVVMExample.xcodeproj.
    * Select your iOS 17+ simulator or device.
3. Build & Run:
    * Press Cmd + R to build and run.
    * Grant Core Data permissions if prompted (automatic on simulator).
4. Core Data Setup (One-Time):
    * In Xcode, go to Editor > Create NSManagedObject Subclass for the Todo entity.
    * Ensure the persistent container is configured in App.swift or your root view.
Usage
1. Launch the App: See accept location alert
2. You can change sound from settings,haptic effects and background
3. change different locations on simulator to see the different temperature and degrees
4. add to favourite by clicking on the heart botton 
5. store offline data also 
