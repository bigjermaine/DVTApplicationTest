import Foundation
import SwiftUI
import CoreData
import Combine

@MainActor
final class CoreDataWeatherViewModel: ObservableObject {
    @Published var savedEntity: [WeatherEntity] = []
    @Published var dailyForecasts: [DailyForecast] = []

    let container: NSPersistentContainer

    init(containerName: String = "WeatherCoreData") {
        self.container = NSPersistentContainer(name: containerName)
        self.container.loadPersistentStores { _, _ in }
        fetchSavedWeatherInfos()
    }
    
    
    
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

    func addWeather(_ item: DailyForecast) {
        let request = NSFetchRequest<WeatherEntity>(entityName: "WeatherEntity")
        request.predicate = NSPredicate(format: "day == %@", item.day)
        do {
            let context = container.viewContext
            if let existing = try context.fetch(request).first {
                var didChange = false
                let newMax = Int32(item.maxTemp)
                let newMin = Int32(item.minTemp)
                let newIcon = item.icon
                let newDay = item.day

                if existing.maxTemp != newMax { existing.maxTemp = newMax; didChange = true }
                if existing.minTep != newMin { existing.minTep = newMin; didChange = true }
                if existing.icon != newIcon { existing.icon = newIcon; didChange = true }
                if existing.day != newDay { existing.day = newDay; didChange = true }

                if didChange {
                    save()
                    if let idx = dailyForecasts.firstIndex(where: { $0.day == newDay }) {
                        dailyForecasts[idx] = DailyForecast(day: newDay, minTemp: Int(newMin), maxTemp: Int(newMax), icon: newIcon)
                    }
                }
            } else {
                let newWeather = WeatherEntity(context: container.viewContext)
                newWeather.maxTemp = Int32(item.maxTemp)
                newWeather.minTep = Int32(item.minTemp)
                newWeather.icon = item.icon
                newWeather.day = item.day
                save()
                if dailyForecasts.contains(where: { $0.day == item.day }) == false {
                    dailyForecasts.append(item)
                }
            }
        } catch {
            let newWeather = WeatherEntity(context: container.viewContext)
            newWeather.maxTemp = Int32(item.maxTemp)
            newWeather.minTep = Int32(item.minTemp)
            newWeather.icon = item.icon
            newWeather.day = item.day
            save()
            if dailyForecasts.contains(where: { $0.day == item.day }) == false {
                dailyForecasts.append(item)
            }
        }
    }

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
        if dailyForecasts.isEmpty {
            dailyForecasts = forecasts
            fetchSavedWeatherInfos()
        }
    }

    func deleteAllSavedForecasts() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "WeatherEntity")
        let batchDelete = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try container.viewContext.execute(batchDelete)
            try container.viewContext.save()
        } catch {
            // ignore
        }
        savedEntity.removeAll()
    }

    func save() {
        do {
            try container.viewContext.save()
        } catch {
            // ignore
        }
    }
}
