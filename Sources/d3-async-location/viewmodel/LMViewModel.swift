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
            await update(coordinate: coordinate)
        }
    }
    
    /// Start streaming locations
    public func stop(){
        manager.stop()
    }
    
    // MARK: - Private
    
    
    @MainActor
    private func update(coordinate : CLLocation) {
        locations.append(coordinate)
    }

}
