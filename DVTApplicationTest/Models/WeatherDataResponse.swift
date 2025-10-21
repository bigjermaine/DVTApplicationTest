//
//  WeatherResponse.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//


import Foundation

// MARK: - Common Models
struct WeatherData: Codable, Identifiable {
    let id = UUID()
    let dt: Int?
    let main: MainWeather?
    let weather: [WeatherElement]?
    let clouds: Clouds?
    let wind: Wind?
    let visibility: Int?
    let pop: Double?
    let rain: Rain?
    let sys: ForecastSys?
    let dtTxt: String?
    
    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, sys
        case dtTxt = "dt_txt"
    }
}


struct MainWeather: Codable {
    let temp: Double
    let feelsLike: Double
    let tempMin: Double
    let tempMax: Double
    let pressure: Int
    let humidity: Int
    let seaLevel: Int?
    let grndLevel: Int?
    let tempKf: Double?
    
    enum CodingKeys: String, CodingKey {
        case temp
        case feelsLike = "feels_like"
        case tempMin = "temp_min"
        case tempMax = "temp_max"
        case pressure, humidity
        case seaLevel = "sea_level"
        case grndLevel = "grnd_level"
        case tempKf = "temp_kf"
    }
}

struct WeatherElement: Codable {
    let id: Int
    let main: String
    let description: String
    let icon: String
}


extension WeatherData {
    var temperatureCelsius: Int? {
        guard let kelvin = main?.temp else { return nil }
        return Int(kelvin - 273.15)
    }
    
    var feelsLikeCelsius: Int? {
        guard let kelvin = main?.feelsLike else { return nil }
        return Int(kelvin - 273.15)
    }
    
    var maxCelsius: Int? {
        guard let kelvin = main?.tempMax else { return nil }
        return Int(kelvin - 273.15)
    }
    
    var minCelsius: Int? {
        guard let kelvin = main?.tempMin else { return nil }
        return Int(kelvin - 273.15)
    }
}
extension Array where Element == WeatherData {
    func dailySummaries() -> [DailyForecast] {
        let grouped = Dictionary(grouping: self) { item in
            String(item.dtTxt?.prefix(10) ?? "")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"

        let daily = grouped.compactMap { (date, items) -> (date: Date, forecast: DailyForecast)? in
            guard let first = items.first else { return nil }

            let minTemp = items.compactMap { $0.minCelsius }.min() ?? 0
            let maxTemp = items.compactMap { $0.maxCelsius }.max() ?? 0

            let condition = first.weather?.first?.main.lowercased() ?? "clear"
            let simplified: String
            if condition.contains("rain") {
                simplified = "rain"
            } else if condition.contains("cloud") {
                simplified = "partlysunny"
            } else {
                simplified = "clear"
            }

            guard let dateObj = formatter.date(from: date) else { return nil }
            formatter.dateFormat = "EEEE"
            let weekday = formatter.string(from: dateObj)

            let forecast = DailyForecast(
                day: weekday,
                minTemp: minTemp,
                maxTemp: maxTemp,
                icon: simplified
            )

            return (date: dateObj, forecast: forecast)
        }

      
        return daily
            .sorted { $0.date < $1.date }
            .prefix(5)
            .map { $0.forecast }
    }
}


extension Array where Element == WeatherData {
    func nextFiveDays(timezoneOffsetSeconds: Int) -> [DailyForecast] {
        let tz = TimeZone(secondsFromGMT: timezoneOffsetSeconds) ?? .gmt
        var cal = Calendar(identifier: .gregorian)
        cal.timeZone = tz

      
        let nowLocal = Date().addingTimeInterval(TimeInterval(timezoneOffsetSeconds))

       
        let upcoming = self.filter { item in
            guard let dt = item.dt else { return false }
            let local = Date(timeIntervalSince1970: TimeInterval(dt) + TimeInterval(timezoneOffsetSeconds))
            return local >= nowLocal
        }

      
        let grouped = Dictionary(grouping: upcoming) { item -> Date in
            let local = Date(timeIntervalSince1970: TimeInterval(item.dt ?? 0) + TimeInterval(timezoneOffsetSeconds))
            let comps = cal.dateComponents([.year, .month, .day], from: local)
            return cal.date(from: comps)!
        }

        // Create summaries per day
        let summaries: [(date: Date, forecast: DailyForecast)] = grouped.compactMap { (date, items) in
          

            let minTemp = items.compactMap {
                if let v = $0.minCelsius { return Double(v) }
                if let k = $0.main?.tempMin { return k - 273.15 }
                return nil
            }.min() ?? 0

            let maxTemp = items.compactMap {
                if let v = $0.maxCelsius { return Double(v) }
                if let k = $0.main?.tempMax { return k - 273.15 }
                return nil
            }.max() ?? 0

            let conditionCounts = Dictionary(grouping: items.compactMap { $0.weather?.first?.main.lowercased() }) { $0 }
                .mapValues(\.count)
            let dominantCondition = conditionCounts.max(by: { $0.value < $1.value })?.key ?? "clear"

            let icon: String
            if dominantCondition.contains("rain") { icon = "rain" }
            else if dominantCondition.contains("cloud") { icon = "partlysunny" }
            else { icon = "clear" }

            let df = DateFormatter()
            df.timeZone = tz
            df.dateFormat = "EEEE"
            let weekday = df.string(from: date)
            
            return (date, DailyForecast(day: weekday, minTemp: Int(minTemp), maxTemp: Int(maxTemp), icon: icon))
        }

        return summaries
            .sorted { $0.date < $1.date }
            .suffix(5)
            .map { $0.forecast }
    }
}
