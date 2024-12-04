//
//  ILocationDelegate.swift
//  
//
//  Created by Igor on 05.07.2023.
//

import Foundation
import CoreLocation

/// A protocol that defines the interface for location delegates.
@available(iOS 14.0, watchOS 7.0, *)
public protocol ILocationDelegate: NSObjectProtocol, CLLocationManagerDelegate {
    
    /// Starts the location streaming process.
    ///
    /// - Returns: An `AsyncStream` emitting `LocationStreamer.Output` values.
    ///   The stream provides asynchronous location updates or errors to the consumer.
    func start() -> AsyncStream<LocationStreamer.Output>
    
    /// Stops the location streaming process.
    ///
    /// Cleans up resources, stops receiving location updates,
    /// and ensures that any ongoing streams are properly terminated.
    func finish()
    
    /// Requests the necessary location permissions from the user if not already granted.
    ///
    /// - Throws: An error if the permission request fails or the user denies access.
    ///
    /// This method should be called before starting the location updates to ensure that the app has the required permissions.
    func permission() async throws
}
