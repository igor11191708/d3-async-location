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
    
    /// Check status and get stream of async data
    private var getStream : AsyncStream<CLLocation>?{
        get async throws {
            if await getStatus{
                return try manager.locations
            }
            throw LocationManagerErrors.accessIsNotAuthorized
        }
    }
    
    /// Get status
    private var getStatus: Bool{
        get async{
            let isAuthorized = await manager.requestPermission()
            return check(status: isAuthorized)
        }
    }
    
    // MARK: - Life circle
    
    public init(accuracy : CLLocationAccuracy? = nil){
        manager = LocationManagerAsync(accuracy: accuracy)
        
    }
    
    deinit{
        #if DEBUG
        print("deinit LocationManagerViewModel")
        #endif
    }
    
    // MARK: - API
    
    /// Start streaming locations
    public func start() async throws{
            if let stream = try await getStream{
                for await coordinate in stream{
                    await update(coordinate: coordinate)
                }
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
    
    private func check(status : CLAuthorizationStatus) -> Bool{
        [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
    }

}
