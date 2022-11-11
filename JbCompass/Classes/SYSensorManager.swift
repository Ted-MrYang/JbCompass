//
//  SYSensorManager.swift
//  CompassExample
//
//  Created by biubiu on 2022/11/10.
//  Copyright © 2022 LC. All rights reserved.
//

import UIKit
import AudioToolbox
import CoreMotion
import CoreLocation

class SYSensorManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = SYSensorManager()
    
    private var locManager: CLLocationManager!
    private var motionManager: CMMotionManager!
    
    public var updateDeviceMotionBlock: ((CMDeviceMotion) -> Void) = { _ in }
    public var didUpdateHeadingBlock: ((CLLocationDirection, CLLocationDirection) -> Void) = { _,_ in }
    
    public func startSensor() {
        locManager = CLLocationManager()
        locManager.delegate = self
        
        if CLLocationManager.headingAvailable() {
            locManager.headingFilter = 5
            locManager.startUpdatingHeading()
        }
    }
    
    public func startGyroscope() {
        motionManager = CMMotionManager()
        motionManager.deviceMotionUpdateInterval = 0.01
        if !motionManager.isAccelerometerActive {
            motionManager.startDeviceMotionUpdates(to: .main) { [weak self] data, error in
                guard let data = data else { return }
                self?.updateDeviceMotionBlock(data)
            }
        }
    }
    
    public func stopSensor() {
        locManager.stopUpdatingHeading()
        locManager = nil
    }
    
    public func stopGyroscope() {
        motionManager.stopGyroUpdates()
        motionManager = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        if newHeading.headingAccuracy < 0 {
            return
        }
        
        let thHeading = newHeading.trueHeading > 0 ? newHeading.trueHeading : newHeading.magneticHeading
        
        self.didUpdateHeadingBlock(thHeading, newHeading.magneticHeading)
    }
}
