//
//  Delegate.swift
//
//
//  Created by Igor on 07.02.2023.
//

import CoreLocation


extension LocationManagerAsync {
    
    /// Delegate class that implements `CLLocationManagerDelegate` methods to receive location updates
    /// and errors from `CLLocationManager`, and forwards them into an `AsyncStream` for asynchronous consumption.
    @available(iOS 14.0, watchOS 7.0, *)
    final class Delegate: NSObject, ILocationDelegate {
        
        typealias DelegateContinuation = AsyncStream<LocationStreamer.Output>.Continuation
        
        /// The `CLLocationManager` instance used to obtain location updates.
        private let manager: CLLocationManager
        
        /// The continuation used to emit location updates or errors into the `AsyncStream`.
        /// When set, starts location updates and sets up termination handling.
        public var continuation: DelegateContinuation? {
            didSet {
                continuation?.onTermination = { [weak self] termination in
                    self?.finish()
                }
                manager.startUpdatingLocation()
            }
        }
        
        // MARK: - Lifecycle
        
        /// Initializes the delegate with specified location settings.
        /// - Parameters:
        ///   - accuracy: The desired accuracy of the location data.
        ///   - activityType: The type of user activity associated with the location updates.
        ///   - distanceFilter: The minimum distance (in meters) the device must move before an update event is generated.
        ///   - backgroundUpdates: A Boolean indicating whether the app should receive location updates when suspended.
        public init(
            _ accuracy: CLLocationAccuracy?,
            _ activityType: CLActivityType?,
            _ distanceFilter: CLLocationDistance?,
            _ backgroundUpdates: Bool = false
        ) {
            manager = CLLocationManager()
            super.init()
            manager.delegate = self
            updateSettings(accuracy, activityType, distanceFilter, backgroundUpdates)
        }
        
        /// Initializes the delegate with a given `CLLocationManager` instance.
        /// - Parameter locationManager: The `CLLocationManager` instance to manage location updates.
        public init(locationManager: CLLocationManager) {
            manager = locationManager
            super.init()
            manager.delegate = self
        }
        
        /// Deinitializer to clean up resources and stop location updates.
        deinit {
            finish()
            manager.delegate = nil
#if DEBUG
            print("deinit delegate")
#endif
        }
        
        // MARK: - API
        
        /// Stops location updates and finishes the `AsyncStream`.
        public func finish() {
            continuation?.finish()
            continuation = nil
            manager.stopUpdatingLocation()
        }
        
        /// Requests location permissions if not already granted.
        /// - Throws: An error if the permission is not granted.
        public func permission() async throws {
            let permission = Permission(with: manager.authorizationStatus)
            try await permission.grant(for: manager)
        }
        
        // MARK: - Delegate
        
        /// Called when new location data is available.
        /// - Parameters:
        ///   - manager: The location manager providing the update.
        ///   - locations: An array of new `CLLocation` objects.
        /// Forwards the locations as a success result to the async stream.
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            enqueue(result: .success(locations))
        }
        
        /// Called when the location manager's authorization status changes.
        /// - Parameter manager: The location manager reporting the change.
        /// Posts a notification with the new authorization status.
        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            NotificationCenter.default.post(name: Permission.authorizationStatus, object: manager.authorizationStatus)
        }
        
        /// Called when the location manager fails to retrieve a location.
        /// - Parameters:
        ///   - manager: The location manager reporting the failure.
        ///   - error: The error that occurred.
        /// Forwards the error as a failure result to the async stream.
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            let cleError = error as? CLError ?? CLError(.locationUnknown)
            continuation?.yield(.failure(cleError))
        }
        
        // MARK: - Private
        
        /// Sets the location manager's properties.
        /// - Parameters:
        ///   - accuracy: The desired accuracy of the location data.
        ///   - activityType: The type of user activity associated with the location updates.
        ///   - distanceFilter: The minimum distance (in meters) the device must move before an update event is generated.
        ///   - backgroundUpdates: A Boolean indicating whether the app should receive location updates when suspended.
        private func updateSettings(
            _ accuracy: CLLocationAccuracy?,
            _ activityType: CLActivityType?,
            _ distanceFilter: CLLocationDistance?,
            _ backgroundUpdates: Bool = false
        ) {
            manager.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
            manager.activityType = activityType ?? .other
            manager.distanceFilter = distanceFilter ?? kCLDistanceFilterNone
            #if os(iOS) || os(watchOS)
            manager.allowsBackgroundLocationUpdates = backgroundUpdates
            #endif
        }
        
        /// Passes a location result (success or failure) into the async stream.
        /// - Parameter result: The result containing locations or an error.
        private func enqueue(result: LocationStreamer.Output) {
            continuation?.yield(result)
        }
    }
}
