//
//  LocationManagerViewModel.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import SwiftUI
import CoreLocation

/// Viewmodel posting locations
@available(iOS 15.0, *)
public final class LMViewModel: ILocationManagerViewModel{
    
    // MARK: - Public
    
    /// List of locations
    @MainActor @Published public private(set) var locations : [CLLocation] = []
            
    // MARK: - Private
    
    /// Async locations manager
    private let manager : LocationManagerAsync
        
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
        for await coordinate in try await manager.start{
            await add(coordinate)
        }
    }
    
    /// Start streaming locations
    public func stop(){
        manager.stop()
    }
    
    // MARK: - Private
    
    
    @MainActor
    private func add(_ coordinate : CLLocation) {
        locations.append(coordinate)
    }

}
