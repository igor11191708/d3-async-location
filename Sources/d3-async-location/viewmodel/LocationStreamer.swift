//
//  LocationManagerViewModel.swift
//
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation

/// ViewModel for asynchronously posting location updates.
/// Add or inject `LocationStreamer` into a View:
/// ```
/// @EnvironmentObject var model: LocationStreamer
/// ```
/// Use the `start()` method within an async environment to start an asynchronous stream of updates.
@available(iOS 14.0, watchOS 7.0, *)
public final class LocationStreamer: ILocationManagerViewModel {
    
    /// Represents the output of the location manager.
    /// Contains either a list of results (e.g., `CLLocation` objects) or a `CLError` in case of failure.
    public typealias Output = Result<[CLLocation], CLError>
    
    // MARK: - Public Properties
    
    /// Strategy for publishing updates. Default value is `.keepLast`.
    public let strategy: Strategy
    
    /// A list of results published for subscribed Views.
    /// Results may include various types of data (e.g., `CLLocation` objects) depending on the implementation.
    /// Use this publisher to feed Views with updates or create a proxy to manipulate the flow,
    /// such as filtering, mapping, or dropping results.
    @MainActor @Published public private(set) var results: [Output] = []
    
    /// Current streaming state of the ViewModel.
    @MainActor @Published public private(set) var state: LocationStreamingState = .idle
            
    // MARK: - Private Properties
    
    /// The asynchronous locations manager responsible for streaming updates.
    private let manager: LocationManagerAsync
    
    /// Indicates whether the streaming process is idle.
    @MainActor
    public var isIdle: Bool {
        return state == .idle
    }
       
    // MARK: - Lifecycle

    /// Initializes the `LocationStreamer`.
    /// - Parameters:
    ///   - strategy: Strategy for publishing updates. Default value is `.keepLast`.
    ///   - accuracy: The accuracy of geographical coordinates.
    ///   - activityType: The type of activity associated with location updates.
    ///   - distanceFilter: The minimum distance (in meters) to trigger location updates.
    ///   - backgroundUpdates: Indicates whether the app receives location updates when running in the background.
    public init(
        strategy: Strategy = .keepLast,
        accuracy: CLLocationAccuracy? = kCLLocationAccuracyBest,
        activityType: CLActivityType? = nil,
        distanceFilter: CLLocationDistance? = nil,
        backgroundUpdates: Bool = false
    ) {
        self.strategy = strategy
        manager = .init(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    /// Initializes the `LocationManagerAsync` instance with a specified publishing strategy and `CLLocationManager`.
    /// - Parameters:
    ///   - strategy: The strategy for publishing location updates. Defaults to `.keepLast`, which retains only the most recent update.
    ///   - locationManager: A pre-configured `CLLocationManager` instance used to manage location updates.
    public init(
        strategy: Strategy = .keepLast,
        locationManager: CLLocationManager
    ) {
        self.strategy = strategy
        manager = .init(locationManager: locationManager)
    }
    
    deinit {
        #if DEBUG
        print("deinit LocationStreamer")
        #endif
    }
    
    // MARK: - API
    
    /// Starts streaming updates asynchronously.
    /// - Throws: `AsyncLocationErrors.streamingProcessHasAlreadyStarted` if streaming is already active.
    @MainActor public func start() async throws {
        if state == .streaming {
            stop()
        }
        
        clean()
        setState(.streaming)
        
        let stream = try await manager.start()
        
        for await result in stream {
            add(result)
        }
        setState(.idle)
    }
    
    /// Stops the streaming process and resets the state to idle.
    @MainActor public func stop() {
        manager.stop()
        setState(.idle)
        
        #if DEBUG
        print("stop manager")
        #endif
    }
    
    // MARK: - Private Methods
    
    @MainActor
    private func clean(){
        results = []
    }
    
    /// Adds a new result to the `results` array based on the publishing strategy.
    /// - Parameter result: The new result to be added.
    @MainActor
    private func add(_ result: Output) {
        switch strategy {
        case .keepAll:
            results.append(result)
        case .keepLast:
            results = [result]
        }
    }
        
    /// Updates the current state of the ViewModel.
    /// - Parameter value: The new streaming state to set.
    @MainActor
    private func setState(_ value: LocationStreamingState) {
        state = value
    }
}
