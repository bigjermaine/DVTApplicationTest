import Foundation
import SwiftUI
import CoreData
import Combine

/// A main-actor isolated view model that wraps Core Data operations for weather forecasts.
/// Responsible for loading, mapping, sorting, and persisting `DailyForecast` data via `WeatherEntity`.
/// Provides a simple API for replacing, adding, and deleting forecasts while keeping published state in sync.
@MainActor
final class CoreDataWeatherViewModel: ObservableObject {
    /// Raw Core Data entities fetched from the persistent store.
    @Published var savedEntity: [WeatherEntity] = []
    /// App-facing, mapped forecasts derived from Core Data, sorted for display.
    @Published var dailyForecasts: [DailyForecast] = []
    
    /// The Core Data persistent container used for all CRUD operations.
    /// Can be injected for testing; defaults to a container named "WeatherCoreData".
    let container: NSPersistentContainer
    
    /// Initializes the view model.
    /// - Parameters:
    ///   - container: Optional persistent container to use (useful for tests). If `nil`, a default container named "WeatherCoreData" is created.
    ///   - useInMemory: When `true` and using the default container, configures an in-memory store for ephemeral testing.
    /// On initialization, the persistent stores are loaded (best-effort) and an initial fetch is performed.
    init(container: NSPersistentContainer? = nil, useInMemory: Bool = false) {
        if let container = container {
            self.container = container
        } else {
            // Default container
            self.container = NSPersistentContainer(name: "WeatherCoreData")
            if useInMemory {
                let description = NSPersistentStoreDescription()
                description.type = NSInMemoryStoreType
                self.container.persistentStoreDescriptions = [description]
            }
            self.container.loadPersistentStores { _, error in
                if let error = error {
                    print("CoreData init error: \(error)")
                }
            }
        }
        fetchSavedWeatherInfos()
    }
    
    /// Loads `WeatherEntity` objects from Core Data, maps them to `DailyForecast`, and sorts them by weekday relative to today.
    /// Sorting attempts to interpret localized weekday names (full, short, very short) and order them from today forward.
    /// Updates both `savedEntity` and `dailyForecasts`.
    func fetchSavedWeatherInfos() {
        let request = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
        request.sortDescriptors = [NSSortDescriptor(key: "day", ascending: false)]
        do {
            savedEntity = try container.viewContext.fetch(request)
            let forecasts: [DailyForecast] = savedEntity.compactMap { entity in
                let day: String = entity.day ?? ""
                let minTemp: Int = Int(entity.minTep)
                let maxTemp: Int = Int(entity.maxTemp)
                let icon: String = entity.icon ?? ""
                return DailyForecast(day: day, minTemp: minTemp, maxTemp: maxTemp, icon: icon)
            }
            let calendar = Calendar.current
            let todayWeekday = calendar.component(.weekday, from: Date())
            let formatter = DateFormatter()
            formatter.locale = Locale.current
            let fullWeekdays = formatter.weekdaySymbols?.map { $0.lowercased() } ?? []
            let shortWeekdays = formatter.shortWeekdaySymbols?.map { $0.lowercased() } ?? []
            let veryShortWeekdays = formatter.veryShortWeekdaySymbols?.map { $0.lowercased() } ?? []
            
            func weekdayIndex(from name: String) -> Int? {
                let key = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
                if let idx = fullWeekdays.firstIndex(of: key) { return idx + 1 }
                if let idx = shortWeekdays.firstIndex(of: key) { return idx + 1 }
                if let idx = veryShortWeekdays.firstIndex(of: key) { return idx + 1 }
                return nil
            }
            let sorted = forecasts.sorted { a, b in
                     let aIdx = weekdayIndex(from: a.day) ?? 8
                     let bIdx = weekdayIndex(from: b.day) ?? 8

                     func offset(_ idx: Int) -> Int {
                         guard (1...7).contains(idx) else { return Int.max }
                         let zeroBased = (idx - 1)
                         let todayZero = (todayWeekday - 1)
                         return (zeroBased - todayZero + 7) % 7
                     }

                     return offset(aIdx) < offset(bIdx)
                 }

                 dailyForecasts = sorted
             } catch {
                 
             }
         }
    /// Maps Core Data entities to `DailyForecast` models with a simple lexicographic day sort.
    /// - Parameter entities: The entities to map.
    /// - Returns: Mapped forecasts, optionally sorted by day string.
    private func mapEntitiesToForecasts(_ entities: [WeatherEntity]) -> [DailyForecast] {
        let forecasts = entities.compactMap {
            DailyForecast(day: $0.day ?? "",
                          minTemp: Int($0.minTep),
                          maxTemp: Int($0.maxTemp),
                          icon: $0.icon ?? "")
        }

        // Optional sorting logic from your original
        return forecasts.sorted(by: { $0.day < $1.day })
    }

    /// Inserts or updates a single forecast by day identifier, then saves and refreshes the in-memory lists.
    /// - Parameter item: The forecast to upsert.
    func addWeather(_ item: DailyForecast) {
        let context = container.viewContext
        let request = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
        request.predicate = NSPredicate(format: "day == %@", item.day)

        do {
            if let existing = try context.fetch(request).first {
                existing.day = item.day
                existing.maxTemp = Int32(item.maxTemp)
                existing.minTep = Int32(item.minTemp)
                existing.icon = item.icon
            } else {
                let new = WeatherEntity(context: context)
                new.day = item.day
                new.maxTemp = Int32(item.maxTemp)
                new.minTep = Int32(item.minTemp)
                new.icon = item.icon
            }
            save()
            fetchSavedWeatherInfos()
        } catch {
            print("Add error: \(error)")
        }
    }

    /// Replaces all saved forecasts with the provided collection, then saves and refreshes.
    /// - Parameter forecasts: The new set of forecasts to persist.
    func replaceAllSavedForecasts(with forecasts: [DailyForecast]) {
        deleteAllSavedForecasts()
        for item in forecasts {
            let entity = WeatherEntity(context: container.viewContext)
            entity.day = item.day
            entity.icon = item.icon
            entity.maxTemp = Int32(item.maxTemp)
            entity.minTep = Int32(item.minTemp)
        }
        save()
        fetchSavedWeatherInfos()
    }

    /// Deletes all `WeatherEntity` records using a batch delete, clears in-memory arrays, and saves the context.
    func deleteAllSavedForecasts() {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherEntity")
        let delete = NSBatchDeleteRequest(fetchRequest: fetch)
        do {
            try container.viewContext.execute(delete)
            try container.viewContext.save()
        } catch {
            print("Delete error: \(error)")
        }
        savedEntity.removeAll()
        dailyForecasts.removeAll()
    }

    /// Saves the current view context. Errors are logged to the console in debug builds.
    func save() {
        do {
            try container.viewContext.save()
        } catch {
            print("Save error: \(error)")
        }
    }
}

