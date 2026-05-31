import CoreMotion
import SwiftUI

// MARK: - Motion Manager for Core Motion
@MainActor
class MotionManager: ObservableObject {
    nonisolated(unsafe) let motionManager = CMMotionManager()

    @Published var pitch: Double = 0.0
    @Published var roll: Double = 0.0
    @Published var yaw: Double = 0.0
    @Published var userAcceleration: (x: Double, y: Double, z: Double) = (0, 0, 0)
    @Published var isAvailable: Bool = false

    init() {
        isAvailable = motionManager.isDeviceMotionAvailable
    }

    func startUpdates() {
        guard motionManager.isDeviceMotionAvailable else { return }

        motionManager.deviceMotionUpdateInterval = 1.0 / 60.0
        motionManager.startDeviceMotionUpdates(to: .main) { [weak self] motion, error in
            guard let motion = motion, error == nil else { return }

            self?.pitch = motion.attitude.pitch
            self?.roll = motion.attitude.roll
            self?.yaw = motion.attitude.yaw
            self?.userAcceleration = (
                x: motion.userAcceleration.x,
                y: motion.userAcceleration.y,
                z: motion.userAcceleration.z
            )
        }
    }

    func stopUpdates() {
        motionManager.stopDeviceMotionUpdates()
    }

    nonisolated deinit {
        motionManager.stopDeviceMotionUpdates()
    }
}
