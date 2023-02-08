//
//  Permission.swift
//  
//
//  Created by Igor on 06.02.2023.
//

import CoreLocation
import Combine
import SwiftUI

extension LocationManagerAsync{
    
    /// Helper class to determine permission to get access for streaming ``CLLocation``
    @available(iOS 15.0, watchOS 7.0, *)
    final class Permission{
        
        /// Name of notification for event location manager changed authorization status
        static let authorizationStatus = Notification.Name("authorizationStatus")
        
        // MARK: - Private properties
        
        /// The current authorization status for the app
        private var status : CLAuthorizationStatus
        
        /// Continuation to get permission if status is not defined
        private var flow : CheckedContinuation<CLAuthorizationStatus, Never>?
        
        /// Check if status is determined
        private var isDetermined : Bool{
            status != .notDetermined
        }
        
        /// Subscription to authorization status changes
        private var cancelable : AnyCancellable?
        
        // MARK: - Life circle
        
        /// Init defining is access to location service is granted
        /// - Parameter status: Constant indicating the app's authorization to use location services
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
        
        
        /// Subscribe for event when location manager change authorization status to go on access permission flow
        private func initSubscription(){
            let name = Permission.authorizationStatus
            cancelable = NotificationCenter.default.publisher(for: name)
                .sink { [weak self] value in
                    self?.statusChanged(value)
                }
        }
        
        /// Determine status after the request permission
        /// - Parameter manager: Location manager
        private func statusChanged(_ value: Output) {
            if let s = value.object as? CLAuthorizationStatus{
                status = s
                flow?.resume(returning: status)
            }
        }
        
        /// Check permission status
        /// - Parameter status: Constant indicating the app's authorization to use location services
        /// - Returns: Return `True` if is allowed
        private func isAuthorized(_ status : CLAuthorizationStatus) -> Bool{
            [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
        }
        
        /// Requests the user’s permission to use location services while the app is in use
        /// Don't forget to add in Info "Privacy - Location When In Use Usage Description" something like "Show list of locations"
        /// - Returns: Permission status
        private func requestPermission(_ manager : CLLocationManager) async -> CLAuthorizationStatus{
            manager.requestWhenInUseAuthorization()
            
            if isDetermined{
                return status
            }
            
            return await withCheckedContinuation{ continuation in
                flow = continuation
            }
        }
    }
    
    // MARK: - Alias types -

    fileprivate typealias Output = NotificationCenter.Publisher.Output
    
}
