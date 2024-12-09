//
//  LocationManagerAsync.swift
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation

/// A location manager that streams data asynchronously using an `AsyncStream`.
/// It requests permission in advance if it hasn't been determined yet.
/// Use the `start()` method to begin streaming location updates.
@available(iOS 14.0, watchOS 7.0, *)
final class LocationManager: ILocationManager {
   
    /// The delegate responsible for handling location updates and forwarding them to the async stream.
    private let delegate: ILocationDelegate
    
    // MARK: - Lifecycle
    
    /// Initializes a new `LocationManagerAsync` instance with the specified settings.
    /// - Parameters:
    ///   - accuracy: The desired accuracy of the location data.
    ///   - activityType: The type of user activity associated with the location updates.
    ///   - distanceFilter: The minimum distance (in meters) that the device must move before an update event is generated. kCLDistanceFilterNone (equivalent to -1.0) means updates are sent regardless of the distance traveled. This is a safe default for apps that don’t require filtering updates based on distance.
    ///   - backgroundUpdates: A Boolean value indicating whether the app should receive location updates when suspended.
    init(
        _ accuracy: CLLocationAccuracy?,
        _ activityType: CLActivityType?,
        _ distanceFilter: CLLocationDistance?,
        _ backgroundUpdates: Bool
    ) {
        delegate = LocationManager.Delegate(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    /// Initializes the `LocationManagerAsync` instance with a specified `CLLocationManager` instance.
    /// - Parameter locationManager: A pre-configured `CLLocationManager` instance used to manage location updates.
    public init(locationManager: CLLocationManager) {
        delegate = LocationManager.Delegate(locationManager: locationManager)
    }
    
    /// Deinitializes the `LocationManagerAsync` instance, performing any necessary cleanup.
    deinit {
        #if DEBUG
            print("deinit manager")
        #endif
    }
    
    // MARK: - API
    
    /// Checks permission status and starts streaming location data asynchronously.
    /// - Returns: An `AsyncStream` emitting location updates or errors.
    /// - Throws: An error if permission is not granted.
    public func start() async throws -> AsyncStream<LocationStreamer.Output> {
        
        try await delegate.permission()

        return delegate.start()
    }
    
    /// Stops the location streaming process.
    public func stop() {
        delegate.finish()
        
        #if DEBUG
            print("stop updating")
        #endif
    }
}
