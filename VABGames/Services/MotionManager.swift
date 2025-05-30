import CoreMotion
import SwiftUI

class MotionManager: ObservableObject {
    static let shared = MotionManager()
    
    private let motionManager = CMMotionManager()
    private var lastShakeTime: Date = Date.distantPast
    private let minimumShakeInterval: TimeInterval = 1.0
    private let shakeThreshold: Double = 2.0
    
    @Published var isShaking: Bool = false
    var onShake: (() -> Void)?
    
    private init() {
        if motionManager.isAccelerometerAvailable {
            motionManager.accelerometerUpdateInterval = 0.1
            startAccelerometerUpdates()
        }
    }
    
    private func startAccelerometerUpdates() {
        motionManager.startAccelerometerUpdates(to: .main) { [weak self] data, error in
            guard let self = self,
                  let acceleration = data?.acceleration,
                  error == nil else { return }
            
            let currentTime = Date()
            let timeSinceLastShake = currentTime.timeIntervalSince(self.lastShakeTime)
            
            // Calculate total acceleration
            let totalAcceleration = sqrt(
                pow(acceleration.x, 2) +
                pow(acceleration.y, 2) +
                pow(acceleration.z, 2)
            ) - 1.0 // Subtract 1 to account for gravity
            
            if totalAcceleration > self.shakeThreshold && timeSinceLastShake > self.minimumShakeInterval {
                self.isShaking = true
                self.lastShakeTime = currentTime
                
                DispatchQueue.main.async {
                    self.onShake?()
                    
                    // Reset shaking state after a short delay
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        self.isShaking = false
                    }
                }
            }
        }
    }
    
    func stopAccelerometerUpdates() {
        motionManager.stopAccelerometerUpdates()
    }
}
