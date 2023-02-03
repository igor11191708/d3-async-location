//
//  LocationManagerAsync.swift
//
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation


/// Manager of locations streaming data asynchronously
@available(iOS 15.0, *)
public final class LocationManagerAsync: NSObject, CLLocationManagerDelegate{
    
    // MARK: - Public properties
    
    public var locations : AsyncStream<CLLocation>{
        get throws {
            try checkStatus()
            return AsyncStream(CLLocation.self) { continuation in
                start(with: continuation)
            }
        }
    }
    
    // MARK: - Private properties
    
    private typealias StreamType = AsyncStream<CLLocation>.Continuation
    
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
        
        managerSettings(accuracy: accuracy)
    }

    override init(){
        
        manager = CLLocationManager()
        
        status = manager.authorizationStatus
        
        super.init()
        
    }
    
    // MARK: - API
    
    /// Request permission
    /// Don't forget to add in Info "Privacy - Location When In Use Usage Description" something like "Show list of locations"
    /// - Returns: Permission status
    public func requestPermission() async -> CLAuthorizationStatus{
        manager.requestWhenInUseAuthorization()
        
        if isDetermined{ return status }
        
        //Suspension point until we get the response from the user according the permission
        return await withCheckedContinuation{ continuation in
            permission = continuation
        }
        
    }
    
    /// Stop updating
    public func stop(){
        stream = nil
        manager.stopUpdatingLocation()
    }
    
    // MARK: - Private
    
    /// Set manager's properties
    /// - Parameter accuracy: Desired accuracy
    private func managerSettings(accuracy : CLLocationAccuracy?){
        manager.delegate = self
        manager.desiredAccuracy = accuracy ?? kCLLocationAccuracyBest
    }
    
    /// Start updating
    private func start(with continuation : StreamType){
        stream = continuation
        manager.startUpdatingLocation()
    }
    
    private func yield(location : CLLocation){
        stream?.yield(location)
    }
    
    private func checkStatus() throws{
        if !isDetermined{
            throw LocationManagerErrors.statusIsNotDetermined
        }
    }
    
    // MARK: - Delegate
    
    /// Pass locations into the async stream
    /// - Parameters:
    ///   - manager: Location manager
    ///   - locations: Array of locations
    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
            locations.forEach{ yield(location: $0) }
    }
    
    /// Determine status after the request permission
    /// - Parameter manager: Location manager
    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            status = manager.authorizationStatus
            permission?.resume(returning: status)
    }
    
}
