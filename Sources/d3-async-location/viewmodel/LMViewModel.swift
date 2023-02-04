//
//  LocationManagerViewModel.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation


/// Viewmodel posting locations
/// Add or inject LMViewModel into a View ```@EnvironmentObject var model: LMViewModel```
/// Call method start() within async environment to start async stream of locations
@available(iOS 15.0, watchOS 7.0, *)
public actor LMViewModel: ILocationManagerViewModel{
    
    // MARK: - Public
    
    /// List of locations
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
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    public init(accuracy : CLLocationAccuracy? = nil, backgroundUpdates : Bool = false){
        manager = LocationManagerAsync(accuracy, backgroundUpdates)
    }
    
    deinit{
        #if DEBUG
        print("deinit LMViewModel")
        #endif
    }
    
    // MARK: - API
    
    /// Start streaming locations
    public func start() async throws{
        if isIdle{
            state = .streaming
            for await coordinate in try await manager.start{
                await add(coordinate)
            }
        }else{
            throw LocationManagerErrors.streamHasAlreadyStarted
        }
    }
    
    /// Start streaming locations
    public func stop(){
        state = .idle
        manager.stop()
    }
    
    // MARK: - Private
    
    @MainActor
    private func add(_ coordinate : CLLocation) {
        locations.append(coordinate)
    }
}
