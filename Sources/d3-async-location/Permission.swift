//
//  Permission.swift
//  
//
//  Created by Igor on 06.02.2023.
//

import CoreLocation

/// Helper class to determine permission to get access for streaming CLLocations
final class Permission{
    
    /// Current status
    private var status : CLAuthorizationStatus
    
    /// Continuation to get permission if status is not defined
    private var permissioning : CheckedContinuation<CLAuthorizationStatus, Never>?
    
    /// Check if status is determined
    private var isDetermined : Bool{
        status != .notDetermined
    }
    
    // MARK: - Life circle
    
    init(status: CLAuthorizationStatus){
        self.status = status
    }
    
    // MARK: - API
    
    /// Get status asynchronously and check is it authorized to start getting the stream of locations
    public func isGranted(for manager: CLLocationManager) async -> Bool{
        let status = await requestPermission(manager)
        return isAuthorized(status)
    }
    
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        status = manager.authorizationStatus
        
        permissioning?.resume(returning: status)
    }
    
    // MARK: - Private methods
    
    /// Check permission status
    /// - Parameter status: Status for checking
    /// - Returns: Return `True` if is allowed
    private func isAuthorized(_ status : CLAuthorizationStatus) -> Bool{
        [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
    }

    private func requestPermission(_ manager : CLLocationManager) async -> CLAuthorizationStatus{
        manager.requestWhenInUseAuthorization()
        
        if status != .notDetermined{
            return status
        }
        
        return await withCheckedContinuation{ continuation in
            permissioning = continuation
        }
    }
    
}
