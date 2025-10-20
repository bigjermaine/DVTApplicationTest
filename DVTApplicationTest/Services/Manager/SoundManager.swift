import Foundation
import AVFoundation
import AudioToolbox

final class SoundManager {
    static let shared = SoundManager()
    
    private init() {
        
        try? AVAudioSession.sharedInstance().setCategory(.ambient, options: [.mixWithOthers])
        try? AVAudioSession.sharedInstance().setActive(true)
    }
    
    public func playTap() {
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            AudioServicesPlaySystemSound(1104)
        }
    }
    
    public func playNotification() {
        if UserDefaults.standard.bool(forKey: "soundEnabled") {
            AudioServicesPlaySystemSound(1007) 
        }
    }
    
    
}
