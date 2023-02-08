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
@available(iOS 15.0, watchOS 7.0, *)
public final class LMViewModel: ILocationManagerViewModel{
    
    // MARK: - Public
    
    /// List of locations Subscribe different Views to locations publisher to feed them
    /// or create a proxy to manipulate with the flow like filtering, dropping, mapping etc
    @MainActor @Published public private(set) var locations : [CLLocation] = []
            
    // MARK: - Private
    
    /// Async locations manager
    private let manager : LocationManagerAsync
    
    /// Current streaming state
    private var state : LocationStreamingState = .idle
    
    /// Check if streaming is idle
    private var isIdle: Bool{
        state == .idle
    }
       
    // MARK: - Life circle

    /// - Parameters:
    ///   - accuracy: The accuracy of a geographical coordinate.
    ///   - activityType: Constants indicating the type of activity associated with location updates.
    ///   - distanceFilter: A distance in meters from an existing location.
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    public init(accuracy : CLLocationAccuracy? = nil,
                activityType: CLActivityType? = nil,
                distanceFilter: CLLocationDistance? = nil,
                backgroundUpdates : Bool = false){
        
        manager = .init(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    deinit{
        #if DEBUG
        print("deinit LMViewModel")
        #endif
    }
    
    // MARK: - API
    
    /// Start streaming locations
    public func start() async throws{
        
        guard isIdle else{
            throw AsyncLocationErrors.streamingProcessHasAlreadyStarted
        }
        
        state = .streaming
        
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
        
            state = .idle

            #if DEBUG
            print("stop manager")
            #endif
    }
    
    // MARK: - Private
        
    /// Add new location
    /// - Parameter coordinate: data
    @MainActor
    private func add(_ coordinate : CLLocation) {
        locations.append(coordinate)
    }
}
