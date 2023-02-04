//
//  LocationManagerAsync.swift
//
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation

fileprivate typealias Termination = AsyncThrowingStream<CLLocation, Error>.Continuation.Termination

///Location manager streaming data asynchronously via instance of ``AsyncStream`` returning from ``start`` asking permission in advance if it's not determined.
@available(iOS 15.0, watchOS 7.0, *)
public final class LocationManagerAsync: NSObject, CLLocationManagerDelegate, ILocationManagerAsync{
   
           
    private typealias StreamType = AsyncThrowingStream<CLLocation, Error>.Continuation
    
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
    private var stream: StreamType?{
        didSet {
            stream?.onTermination = { @Sendable termination in
                self.onTermination(termination)
                
            }
        }
    }
    
    // Authorization
    
    /// Continuation to get permission if status is not defined
    private var permissionAwait : CheckedContinuation<CLAuthorizationStatus,Never>?
       
    /// Current status
    private var status : CLAuthorizationStatus
    
    /// Check if status is determined
    private var isDetermined : Bool{
        status != .notDetermined
    }
    
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
        
        manager = CLLocationManager()
        
        status = manager.authorizationStatus
        
        super.init()
        
    }
    
    // MARK: - API
    
    /// Check status and get stream of async data Throw an error ``LocationManagerErrors`` if permission is not granted
    public var start : AsyncThrowingStream<CLLocation, Error>{
        get async throws {
            if await getPermission{
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
    
    // Authorization
    
    /// Get status asynchronously and check is it authorized to start getting the stream of locations
    private var getPermission: Bool{
        get async{
            let status = await requestPermission()
            return isAuthorized(status)
        }
    }
    
    /// Check permission status
    /// - Parameter status: Status for checking
    /// - Returns: Return `True` if is allowed
    private func isAuthorized(_ status : CLAuthorizationStatus) -> Bool{
        [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
    }
    
    /// Request permission
    /// Don't forget to add in Info "Privacy - Location When In Use Usage Description" something like "Show list of locations"
    /// - Returns: Permission status
    private func requestPermission() async -> CLAuthorizationStatus{
        manager.requestWhenInUseAuthorization()
        
        if isDetermined{ return status }
        
        /// Suspension point until we get permission from the user
        return await withCheckedContinuation{ continuation in
            permissionAwait = continuation
        }
    }
   
    // Streaming locations
    
    /// Start updating
    private func streaming(with continuation : StreamType){
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
    
    /// Precess termination
    /// - Parameter termination: A type that indicates how the stream terminated.
    private func onTermination(_ termination: Termination){
         switch termination {
             case .finished:
             stop()
             case .cancelled:
             stream?.finish(throwing: AsyncLocationErrors.streamCancelled)
         @unknown default:
             stream?.finish(throwing: AsyncLocationErrors.unknownTermination)
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
            status = manager.authorizationStatus
            permissionAwait?.resume(returning: status)
    }
}
