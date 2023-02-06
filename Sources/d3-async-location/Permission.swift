//
//  Permission.swift
//  
//
//  Created by Igor on 06.02.2023.
//

import CoreLocation
import Combine
import SwiftUI

/// Helper class to determine permission to get access for streaming ``CLLocation``
@available(iOS 15.0, watchOS 7.0, *)
final class Permission{
    
    static let authorizationStatus = Notification.Name("authorizationStatus")
    
    // MARK: - Private properties
    
    /// Current status
    private var status : CLAuthorizationStatus
    
    /// Continuation to get permission if status is not defined
    private var permissioning : CheckedContinuation<CLAuthorizationStatus, Never>?
    
    /// Check if status is determined
    private var isDetermined : Bool{ status != .notDetermined }
    
    /// Subscription to authorization status changes
    private var canellable : AnyCancellable?
        
    // MARK: - Life circle
    
    init(with status: CLAuthorizationStatus){
        self.status = status
        initSubscription()
    }
    
    // MARK: - API
    
    /// Get status asynchronously and check is it authorized to start getting the stream of locations
    public func isGranted(for manager: CLLocationManager) async -> Bool{
        let status = await requestPermission(manager)
        return isAuthorized(status)
    }    
    
    // MARK: - Private methods
    
    private func initSubscription(){
        canellable = NotificationCenter.default.publisher(for: Permission.authorizationStatus, object: nil)
            .sink { [weak self] value in
                self?.authorizationChanged(value)
            }
    }
    
    /// Determine status after the request permission
    /// - Parameter manager: Location manager
    private func authorizationChanged(_ value: Output) {
        if let s = value.object as? CLAuthorizationStatus{
            status = s
            permissioning?.resume(returning: status)
            print(status, "authorizationStatus")
        }
    }
    
    /// Check permission status
    /// - Parameter status: Status for checking
    /// - Returns: Return `True` if is allowed
    private func isAuthorized(_ status : CLAuthorizationStatus) -> Bool{
        [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
    }
    
    /// Request permission
    /// Don't forget to add in Info "Privacy - Location When In Use Usage Description" something like "Show list of locations"
    /// - Returns: Permission status
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

// MARK: - Alias types -

fileprivate typealias Output = NotificationCenter.Publisher.Output
