//
//  ObservableLocationStreamer.swift
//
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation

#if compiler(>=5.9) && canImport(Observation)

/// ViewModel for asynchronously posting location updates.
@available(iOS 17.0, watchOS 10.0, *)
@Observable
public final class ObservableLocationStreamer: ILocationStreamer{
    
    /// Represents the output of the location manager.
    /// Contains either a list of results (e.g., `CLLocation` objects) or a `CLError` in case of failure.
    public typealias Output = Result<[CLLocation], CLError>
    
    // MARK: - Public Properties
    
    /// Strategy for publishing updates. Default value is `.keepLast`.
    public let strategy: ILocationResultStrategy
    
    /// A list of results published for subscribed Views.
    /// Results may include various types of data (e.g., `CLLocation` objects) depending on the implementation.
    /// Use this publisher to feed Views with updates or create a proxy to manipulate the flow,
    /// such as filtering, mapping, or dropping results.
    @MainActor public private(set) var results: [Output] = []
    
    /// Current streaming state of the ViewModel.
    @MainActor public private(set) var state: LocationStreamingState = .idle
            
    // MARK: - Private Properties
    
    /// The asynchronous locations manager responsible for streaming updates.
    private let manager: LocationManager
    
    /// Indicates whether the streaming process is idle.
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
        strategy: ILocationResultStrategy = KeepLastStrategy(),
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
        strategy: ILocationResultStrategy = KeepLastStrategy(),
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

#endif
