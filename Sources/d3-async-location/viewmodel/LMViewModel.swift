//
//  LocationManagerViewModel.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation

/// ViewModel posting locations asynchronously
/// Add or inject LMViewModel into a View
/// @EnvironmentObject var model: LMViewModel
/// Call method start() within async environment to start async stream of locations
@available(iOS 14.0, watchOS 7.0, *)
public final class LMViewModel: ILocationManagerViewModel{
    
    // MARK: - Public
    
    /// Strategy for publishing locations Default value is .keepLast
    public let strategy : Strategy
    
    /// List of locations Subscribe different Views to locations publisher to feed them
    /// or create a proxy to manipulate with the flow like filtering, dropping, mapping etc
    @MainActor @Published public private(set) var locations : [CLLocation] = []
            
    // MARK: - Private
    
    /// Async locations manager
    private let manager : LocationManagerAsync
    
    /// Current streaming state
    private var state : LocationStreamingState = .idle
    
    /// Check if streaming is idle
    @MainActor
    private var isIdle: Bool{
        return state == .idle
    }
       
    // MARK: - Life circle

    /// - Parameters:
    ///   - strategy: Strategy for publishing locations Default value is .keepLast
    ///   - accuracy: The accuracy of a geographical coordinate.
    ///   - activityType: Constants indicating the type of activity associated with location updates.
    ///   - distanceFilter: A distance in meters from an existing location.
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    public init(
                strategy : Strategy = .keepLast,
                accuracy : CLLocationAccuracy? = nil,
                activityType: CLActivityType? = nil,
                distanceFilter: CLLocationDistance? = nil,
                backgroundUpdates : Bool = false){
        
        self.strategy = strategy
                    
        manager = .init(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    /// - Parameters:
    ///   - strategy: Strategy for publishing locations Default value is .keepLast
    ///   - delegate: Custom delegate
    public init(
                strategy : Strategy = .keepLast,
                delegate : ILocationDelegate){
        
        self.strategy = strategy
                    
       manager = .init(with: delegate)
    }
    
    deinit{
        #if DEBUG
        print("deinit LMViewModel")
        #endif
    }
    
    // MARK: - API
    
    /// Start streaming locations
    public func start() async throws{
        guard await isIdle else{
            throw AsyncLocationErrors.streamingProcessHasAlreadyStarted
        }
        
        setState(.streaming)        
        
        do {
            for try await coordinate in try await manager.start{
                await add(coordinate)
            }
        }catch{
            
            stop()
            
            throw error
        }
    }
    
    /// Stop streaming locations
    public func stop(){
  
            manager.stop()
        
            setState(.idle)

            #if DEBUG
            print("stop manager")
            #endif
    }
    
    // MARK: - Private
        
    /// Add new location
    /// - Parameter coordinate: data
    @MainActor
    private func add(_ coordinate : CLLocation) {
        if strategy.isKeepAll || locations.isEmpty{
            locations.append(coordinate)
        }else if strategy.isKeepLast{
            locations[0] = coordinate            
        }
    }
        
    /// Set state
    /// - Parameter value: Streaming state
    private func setState(_ value: LocationStreamingState) {
        state = value
    }
}
