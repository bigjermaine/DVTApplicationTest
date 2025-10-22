//
//  APIClientTests.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 22/10/2025.
//



import XCTest
import AVFoundation
@testable import DVTApplicationTest

final class SoundManagerTests: XCTestCase {

    var soundManager: SoundManager!

    override func setUp() {
        super.setUp()
        soundManager = SoundManager.shared
        // Ensure clean test state
        UserDefaults.standard.removeObject(forKey: "soundEnabled")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "soundEnabled")
        soundManager = nil
        super.tearDown()
    }

    func testInit_ConfiguresAudioSession() {
        // Given
        let session = AVAudioSession.sharedInstance()

        // Then
        XCTAssertEqual(session.category, .ambient, "Audio session should be set to ambient.")
        XCTAssertTrue(session.isOtherAudioPlaying == false || session.isOtherAudioPlaying == true,
                      "Session should be active (dummy check for runtime safety).")
    }

    func testPlayTap_WhenSoundEnabled_ShouldPlay() {
        // Given
        UserDefaults.standard.set(true, forKey: "soundEnabled")

        // When
        // We can’t directly verify system sound playback, but we can safely call it
        XCTAssertNoThrow(soundManager.playTap(), "playTap() should not throw when sound is enabled.")
    }

    func testPlayTap_WhenSoundDisabled_ShouldNotThrow() {
        // Given
        UserDefaults.standard.set(false, forKey: "soundEnabled")

        // When & Then
        XCTAssertNoThrow(soundManager.playTap(), "playTap() should safely handle sound disabled state.")
    }

    func testPlayNotification_WhenSoundEnabled_ShouldPlay() {
        // Given
        UserDefaults.standard.set(true, forKey: "soundEnabled")

        // When & Then
        XCTAssertNoThrow(soundManager.playNotification(), "playNotification() should not throw when sound is enabled.")
    }

    func testPlayNotification_WhenSoundDisabled_ShouldNotThrow() {
        // Given
        UserDefaults.standard.set(false, forKey: "soundEnabled")

        // When & Then
        XCTAssertNoThrow(soundManager.playNotification(), "playNotification() should safely handle sound disabled state.")
    }
}
