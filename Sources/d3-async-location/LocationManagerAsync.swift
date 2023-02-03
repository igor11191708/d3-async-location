//
//  LocationManagerAsync.swift
//
//
//  Created by Igor on 03.02.2023.
//
import Foundation
import CoreLocation


///Location manager streaming data asynchronously via property ``locations``
@available(iOS 15.0, *)
public final class LocationManagerAsync: NSObject, ILocationManagerAsync{
       
    private var locations : AsyncStream<CLLocation>{
        AsyncStream(CLLocation.self) { continuation in
                streaming(with: continuation)
            }
    }
    
    private typealias StreamType = AsyncStream<CLLocation>.Continuation
    
    /// Continuation asynchronosly passing location data
    private var stream: StreamType?{
        didSet {
            stream?.onTermination = { @Sendable _ in self.stop() }
        }
    }
    
    /// Continuation to get permission is status is not defined
    private var permission : CheckedContinuation<CLAuthorizationStatus,Never>?
    
    /// Location manager
    private let manager : CLLocationManager
        
    /// Current status
    private var status : CLAuthorizationStatus
    
    /// Check if status is determined
    private var isDetermined : Bool{
        status != .notDetermined
    }
    
    // MARK: - Life circle
    
    public convenience init(accuracy : CLLocationAccuracy?){
        
        self.init()
        
        updateSettings(accuracy: accuracy)
    }

    override init(){
        
        manager = CLLocationManager()
        
        status = manager.authorizationStatus
        
        super.init()
        
    }
    
    // MARK: - API
    
    /// Check status and get stream of async data
    public var start : AsyncStream<CLLocation>{
        get async throws {
            if await getStatus{
                return locations
            }
            throw LocationManagerErrors.accessIsNotAuthorized
        }
    }
    
    /// Stop streaming
    public func stop(){
        stream = nil
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Private
    
    /// Get status
    private var getStatus: Bool{
        get async{
            let isAuthorized = await requestPermission()
            return check(status: isAuthorized)
        }
    }
    
    /// Request permission
    /// Don't forget to add in Info "Privacy - Location When In Use Usage Description" something like "Show list of locations"
    /// - Returns: Permission status
    private func requestPermission() async -> CLAuthorizationStatus{
        manager.requestWhenInUseAuthorization()
        
        if isDetermined{ return status }
        
        //Suspension point until we get the response from the user according the permission
        return await withCheckedContinuation{ continuation in
            permission = continuation
        }
        
    }
    
    /// Set manager's properties
    /// - Parameter accuracy: Desired accuracy
    private func updateSettings(accuracy : CLLocationAccuracy?){
        manager.delegate = self
        manager.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
    }
    
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
    
    /// check permision status
    /// - Parameter status: Status for checking
    /// - Returns: Return `True` if is allowed
    private func check(status : CLAuthorizationStatus) -> Bool{
        [CLAuthorizationStatus.authorizedWhenInUse, .authorizedAlways].contains(status)
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
            permission?.resume(returning: status)
    }
    
}
