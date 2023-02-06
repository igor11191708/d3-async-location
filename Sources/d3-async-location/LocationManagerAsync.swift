//
//  LocationManagerAsync.swift
//
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation

///Location manager streaming data asynchronously via instance of ``AsyncThrowingStream`` returning from ``start`` asking permission in advance if it's not determined.
@available(iOS 15.0, watchOS 7.0, *)
public final class LocationManagerAsync: NSObject, CLLocationManagerDelegate, ILocationManagerAsync{
    
    // MARK: - Private properties
   
    /// Location manager
    private let manager : CLLocationManager
    
    // Streaming locations
    
    /// Async stream of locations
    private var locations : AsyncThrowingStream<CLLocation, Error>{
        .init(CLLocation.self) { continuation in
                streaming(with: continuation)
            }
    }
   
    /// Continuation asynchronously passing location data
    private var stream: Streaming?{
        didSet {
            stream?.onTermination = { @Sendable termination in
                self.onTermination(termination)
                
            }
        }
    }
    
    /// Authorization Permission helper
    private var permission : Permission
    
    // MARK: - Life circle
    
    /// - Parameters:
    ///   - accuracy: The accuracy of a geographical coordinate.
    ///   - backgroundUpdates: A Boolean value that indicates whether the app receives location updates when running in the background
    public convenience init(_ accuracy : CLLocationAccuracy?,
                            _ backgroundUpdates : Bool = false){
        
        self.init()
        
        updateSettings(accuracy, backgroundUpdates)
    }

    override init(){
        
        manager = .init()
        permission = .init(status: manager.authorizationStatus)
        
        super.init()
        
    }
    
    // MARK: - API
    
    /// Check status and get stream of async data Throw an error ``LocationManagerErrors`` if permission is not granted
    public var start : AsyncThrowingStream<CLLocation, Error>{
        get async throws {
            if await permission.isGranted(for: manager){
                #if DEBUG
                print("start")
                #endif
                return locations
            }
            throw AsyncLocationErrors.accessIsNotAuthorized
        }
    }
    
    /// Stop streaming
    public func stop(){
        stream = nil
        manager.stopUpdatingLocation()
        
        #if DEBUG
        print("stop updating")
        #endif
    }
    
    // MARK: - Private
   
    // Streaming locations
    
    /// Start updating
    private func streaming(with continuation : Streaming){
        stream = continuation
        manager.startUpdatingLocation()
    }
    
    /// Passing location data
    /// - Parameter location: Location data
    private func pass(location : CLLocation){
        stream?.yield(location)
    }
    
    // Helpers
    
    /// Set manager's properties
    /// - Parameter accuracy: Desired accuracy
    private func updateSettings(_ accuracy : CLLocationAccuracy?,
                                _ backgroundUpdates : Bool = false){
        manager.delegate = self
        manager.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
        manager.allowsBackgroundLocationUpdates = backgroundUpdates
    }
    
    /// Process termination
    /// - Parameter termination: A type that indicates how the stream terminated.
    private func onTermination(_ termination: Termination){
        let type = AsyncLocationErrors.self
         switch termination {
              case .finished: stop()
             case .cancelled: stream?.finish(throwing: type.streamCancelled)
            @unknown default: stream?.finish(throwing: type.unknownTermination)
         }
     }
    
    // MARK: - Delegate
    
    /// Pass locations into the async stream
    /// - Parameters:
    ///   - manager: Location manager
    ///   - locations: Array of locations
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locations.forEach{ pass(location: $0) }
    }
    
    /// Determine status after the request permission
    /// - Parameter manager: Location manager
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        permission.locationManagerDidChangeAuthorization(manager)
    }
}

// MARK: - Alias types -

fileprivate typealias Termination = AsyncThrowingStream<CLLocation, Error>.Continuation.Termination

fileprivate typealias Streaming = AsyncThrowingStream<CLLocation, Error>.Continuation
