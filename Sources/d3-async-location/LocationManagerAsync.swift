//
//  LocationManagerAsync.swift
//
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation

///Location manager streaming data asynchronously via instance of `AsyncThrowingStream` returning from ``start`` asking permission in advance if it's not determined.
@available(iOS 14.0, watchOS 7.0, *)
final class LocationManagerAsync: ILocationManagerAsync{
    
    // MARK: - Private properties
    
    /// Location manager
    private let manager = CLLocationManager()
    
    /// Delegate
    private let delegate = Delegate()
    
    // Streaming locations
    
    /// Async stream of ``CLLocation``
    private var locations : AsyncThrowingStream<CLLocation, Error>{
        .init(CLLocation.self) { continuation in
            streaming(with: continuation)
        }
    }
    
    // MARK: - Life circle
    
    /// - Parameters:
    ///   - accuracy: The accuracy of a geographical coordinate.
    ///   - activityType: Constants indicating the type of activity associated with location updates.
    ///   - distanceFilter: A distance in meters from an existing location.
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    init(_ accuracy : CLLocationAccuracy?,
         _ activityType: CLActivityType?,
         _ distanceFilter: CLLocationDistance?,
         _ backgroundUpdates : Bool = false){
        
        updateSettings(accuracy, activityType, distanceFilter, backgroundUpdates)
    }
    
    
    // MARK: - API
    
    /// Check status and get stream of async data Throw an error ``AsyncLocationErrors`` if permission is not granted
    public var start : AsyncThrowingStream<CLLocation, Error>{
        get async throws {
            let permission = Permission(with: manager.authorizationStatus)
            
            try await permission.grant(for: manager)
            
            #if DEBUG
            print("start")
            #endif
            
            return locations
            
        }
    }
    
    /// Stop streaming
    public func stop(){
        delegate.finish()
        manager.stopUpdatingLocation()
        
        #if DEBUG
        print("stop updating")
        #endif
    }
    
    // MARK: - Private
    
    // Streaming locations
    
    /// Start updating
    private func streaming(with continuation : Streaming){
        delegate.setStream(with: continuation)
        manager.startUpdatingLocation()
    }
    
    // Helpers
    
    /// Set manager's properties
    /// - Parameters:
    ///   - accuracy: The accuracy of a geographical coordinate.
    ///   - activityType: Constants indicating the type of activity associated with location updates.
    ///   - distanceFilter: A distance in meters from an existing location.
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    private func updateSettings(_ accuracy : CLLocationAccuracy?,
                                _ activityType: CLActivityType?,
                                _ distanceFilter: CLLocationDistance?,
                                _ backgroundUpdates : Bool = false
    ){
        manager.delegate = delegate
        manager.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
        manager.activityType = activityType ?? .other
        manager.distanceFilter = distanceFilter ?? kCLDistanceFilterNone
        manager.allowsBackgroundLocationUpdates = backgroundUpdates
    }
}
