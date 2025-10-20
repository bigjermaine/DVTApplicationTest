//
//  MockWeatherManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 20/10/2025.
//


import XCTest
@testable import DVTApplicationTest

final class WeatherStateStorageTests: XCTestCase {
    
    var sut: WeatherStateStorage!
    var testUserDefaults: UserDefaults!
    
    override func setUp() {
        super.setUp()
        testUserDefaults = UserDefaults(suiteName: "WeatherStateStorageTests")!
        sut = WeatherStateStorage()
        
    
    }
    
    override func tearDown() {
        
        testUserDefaults.removePersistentDomain(forName: "WeatherStateStorageTests")
        testUserDefaults.synchronize()
        sut = nil
        testUserDefaults = nil
        super.tearDown()
    }
    
    
    func testLoadWeatherType_WhenSunnySaved_ReturnsSunny() {
        // Given
        let sunnyType: WeatherType = .sunny
        sut.saveWeatherType(sunnyType)
        
        // When
        let loadedType = sut.loadWeatherType()
        
        // Then
        XCTAssertEqual(loadedType, sunnyType)
        XCTAssertEqual(loadedType?.rawValue, "SUNNY")
    }
    
    func testLoadWeatherType_WhenCloudySaved_ReturnsCloudy() {
        // Given
        let cloudyType: WeatherType = .cloudy
        sut.saveWeatherType(cloudyType)
        
        // When
        let loadedType = sut.loadWeatherType()
        
        // Then
        XCTAssertEqual(loadedType, cloudyType)
        XCTAssertEqual(loadedType?.rawValue, "CLOUDY")
    }
    
    func testLoadWeatherType_WhenRainySaved_ReturnsRainy() {
        // Given
        let rainyType: WeatherType = .rainy
        sut.saveWeatherType(rainyType)
        
        // When
        let loadedType = sut.loadWeatherType()
        
        // Then
        XCTAssertEqual(loadedType, rainyType)
        XCTAssertEqual(loadedType?.rawValue, "RAINY")
    }
    
    func testLoadWeatherType_WhenNoneSaved_ReturnsNone() {
        // Given
        let noneType: WeatherType = .none
        sut.saveWeatherType(noneType)
        
        // When
        let loadedType = sut.loadWeatherType()
        
        // Then
        XCTAssertEqual(loadedType, noneType)
        XCTAssertEqual(loadedType?.rawValue, "None")
    }
 
}
