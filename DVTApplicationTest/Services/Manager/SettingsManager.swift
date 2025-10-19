//
//  SettingsManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation


enum SettingsKeys {
    static let hapticsEnabled = "hapticsEnabled"
    static let designStyle = "designStyle"
    static let soundEnabled = "soundEnabled"
}


extension UserDefaults {
var hapticsEnabled: Bool {
    get { bool(forKey: SettingsKeys.hapticsEnabled) }
    set { set(newValue, forKey: SettingsKeys.hapticsEnabled) }
}

var designStyle: String {
    get { string(forKey: SettingsKeys.designStyle) ?? DesignStyle.system.rawValue }
    set { set(newValue, forKey: SettingsKeys.designStyle) }
}

var soundEnabled: Bool {
    get { bool(forKey: SettingsKeys.soundEnabled) }
    set { set(newValue, forKey: SettingsKeys.soundEnabled) }
}
}
