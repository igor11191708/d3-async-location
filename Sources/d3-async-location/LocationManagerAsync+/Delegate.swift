//
//  Delegate.swift
//
//
//  Created by Igor on 07.02.2023.
//

import CoreLocation

extension LocationManager {
    
    /// Delegate class that implements `CLLocationManagerDelegate` methods to receive location updates
    /// and errors from `CLLocationManager`, and forwards them into an `AsyncFIFOQueue` for asynchronous consumption.
    @available(iOS 14.0, watchOS 7.0, *)
    final class Delegate: NSObject, ILocationDelegate {
        
        typealias DelegateOutput = LocationStreamer.Output
        
        /// The `CLLocationManager` instance used to obtain location updates.
        private let manager: CLLocationManager
        
        /// The FIFO queue used to emit location updates or errors as an asynchronous stream.
        private let fifoQueue: AsyncFIFOQueue<DelegateOutput>
        
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
            self.manager = CLLocationManager()
            self.fifoQueue = AsyncFIFOQueue<DelegateOutput>()
            super.init()
            manager.delegate = self
            updateSettings(accuracy, activityType, distanceFilter, backgroundUpdates)
        }
        
        /// Initializes the delegate with a given `CLLocationManager` instance.
        /// - Parameter locationManager: The `CLLocationManager` instance to manage location updates.
        public init(locationManager: CLLocationManager) {
            self.manager = locationManager
            self.fifoQueue = AsyncFIFOQueue<DelegateOutput>()
            super.init()
            manager.delegate = self
        }
        
        deinit {
            finish()
            manager.delegate = nil
            #if DEBUG
            print("deinit delegate")
            #endif
        }
        
        // MARK: - API
        
        /// Starts location streaming.
        /// - Returns: An async stream of location outputs.
        public func start() -> AsyncStream<DelegateOutput> {
            // Initialize the stream when needed.
            let stream = fifoQueue.initializeQueue()
            
            manager.startUpdatingLocation()
            return stream
        }
        
        /// Stops location updates and finishes the asynchronous FIFO queue.
        public func finish() {
            fifoQueue.finish()
            manager.stopUpdatingLocation()
        }
        
        /// Requests location permissions if not already granted.
        /// - Throws: An error if the permission is not granted.
        public func permission() async throws {
            let permission = Permission(with: manager.authorizationStatus)
            try await permission.grant(for: manager)
        }
        
        // MARK: - Delegate Methods
        
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            fifoQueue.enqueue(.success(locations))
        }
        
        public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            let cleError = error as? CLError ?? CLError(.locationUnknown)
            fifoQueue.enqueue(.failure(cleError))
        }
        
        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            NotificationCenter.default.post(name: Permission.authorizationStatus, object: manager.authorizationStatus)
        }
        
        // MARK: - Private Methods
        
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
    }
}
