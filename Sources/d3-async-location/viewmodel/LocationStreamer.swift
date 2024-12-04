//
//  LocationStreamer.swift
//
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation

/// A ViewModel for asynchronously streaming location updates.
/// This class leverages `ObservableObject` to publish updates for SwiftUI Views.
///
/// Example usage in a View:
/// ```
/// @EnvironmentObject var model: LocationStreamer
/// ```
///
/// To start streaming updates, call the `start()` method within an async environment.
///
/// - Available: iOS 14.0+, watchOS 7.0+
@available(iOS 14.0, watchOS 7.0, *)
public final class LocationStreamer: ILocationStreamer, ObservableObject {
    
    /// Represents the output of the location manager.
    /// Each output is either:
    /// - A list of results (`[CLLocation]` objects), or
    /// - A `CLError` in case of failure.
    public typealias Output = Result<[CLLocation], CLError>
    
    // MARK: - Public Properties
    
    /// Defines the strategy for processing and publishing location updates.
    /// Default strategy retains only the most recent update (`KeepLastStrategy`).
    public let strategy: LocationResultStrategy
    
    /// A list of location results, published for subscribing Views.
    /// This property is updated based on the chosen `strategy`.
    @MainActor @Published public private(set) var results: [Output] = []
    
    /// Indicates the current streaming state of the ViewModel.
    /// State transitions include `.idle`, `.streaming`, and `.error`.
    @MainActor @Published public private(set) var state: LocationStreamingState = .idle
            
    // MARK: - Private Properties
    
    /// Handles the actual location updates asynchronously.
    private let manager: LocationManagerAsync
    
    /// Checks if the streaming process is idle.
    /// A computed property for convenience.
    @MainActor
    public var isIdle: Bool {
        return state == .idle
    }
       
    // MARK: - Lifecycle

    /// Initializes the `LocationStreamer` with configurable parameters.
    /// - Parameters:
    ///   - strategy: A `LocationResultStrategy` for managing location results. Defaults to `KeepLastStrategy`.
    ///   - accuracy: Specifies the desired accuracy of location updates. Defaults to `kCLLocationAccuracyBest`.
    ///   - activityType: The type of activity for location updates (e.g., automotive, fitness). Defaults to `.other`.
    ///   - distanceFilter: The minimum distance (in meters) before generating an update. Defaults to `kCLDistanceFilterNone` (no filtering).
    ///   - backgroundUpdates: Whether the app should continue receiving location updates in the background. Defaults to `false`.
    public init(
        strategy: LocationResultStrategy = KeepLastStrategy(),
        _ accuracy: CLLocationAccuracy? = kCLLocationAccuracyBest,
        _ activityType: CLActivityType? = .other,
        _ distanceFilter: CLLocationDistance? = kCLDistanceFilterNone,
        _ backgroundUpdates: Bool = false
    ) {
        self.strategy = strategy
        manager = .init(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    /// Initializes the `LocationStreamer` with a pre-configured `CLLocationManager`.
    /// - Parameters:
    ///   - strategy: A `LocationResultStrategy` for managing location results. Defaults to `KeepLastStrategy`.
    ///   - locationManager: A pre-configured `CLLocationManager` instance.
    public init(
        strategy: LocationResultStrategy = KeepLastStrategy(),
        locationManager: CLLocationManager
    ) {
        self.strategy = strategy
        manager = .init(locationManager: locationManager)
    }
    
    /// Cleans up resources when the instance is deallocated.
    deinit {
        #if DEBUG
        print("deinit LocationStreamer")
        #endif
    }
    
    // MARK: - API
    
    /// Starts streaming location updates asynchronously.
    /// - Parameters:
    ///   - clean: Whether to clear previous results before starting. Defaults to `true`.
    /// - Throws: `AsyncLocationErrors.streamingProcessHasAlreadyStarted` if streaming is already active.
    @MainActor public func start(clean: Bool = true) async throws {
        if state == .streaming { stop() }
        if clean { self.clean() }
        
        setState(.streaming)
        
        let stream = try await manager.start()
        
        for await result in stream {
            add(result)
        }
        setState(.idle)
    }
    
    /// Stops the location streaming process and sets the state to idle.
    @MainActor public func stop() {
        manager.stop()
        setState(.idle)
        
        #if DEBUG
        print("stop manager")
        #endif
    }
    
    // MARK: - Private Methods
    
    /// Clears all stored results.
    @MainActor
    private func clean() {
        results = []
    }
    
    /// Adds a new location result to the `results` array.
    /// The behavior depends on the configured `strategy`.
    /// - Parameter result: The new result to be processed and added.
    @MainActor
    private func add(_ result: Output) {
        results = strategy.process(results: results, newResult: result)
    }
        
    /// Updates the streaming state of the ViewModel.
    /// - Parameter value: The new state to set (e.g., `.idle`, `.streaming`).
    @MainActor
    private func setState(_ value: LocationStreamingState) {
        state = value
    }
}
