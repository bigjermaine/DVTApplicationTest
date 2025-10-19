//
//  HapticManager.swift
//  DVTApplicationTest
//
//  Created by Daniel Jermaine on 19/10/2025.
//

import Foundation
import UIKit


final class HapticManager {
 static   let shared = HapticManager()
    
    
    private init() {}
    
    public func vibrateForSelection() {
        if  UserDefaults().hapticsEnabled {
            DispatchQueue.main.async {
                let generator = UISelectionFeedbackGenerator()
                generator.prepare()
                generator.selectionChanged()
            }
        }
    }
    
    public func vibrate(for type:UINotificationFeedbackGenerator.FeedbackType) {
        if  UserDefaults().hapticsEnabled {
            DispatchQueue.main.async {
                let generator =  UINotificationFeedbackGenerator()
                generator.prepare()
                generator.notificationOccurred(type)
            }
        }
    }
    
    
}
