//
//  Delegate.swift
//  
//
//  Created by Igor on 07.02.2023.
//

import CoreLocation

extension LocationManagerAsync{
    
    /// The methods that you use to receive events from an associated location-manager object
    /// The location manager calls its delegate’s methods to report location-related events to your app.
    @available(iOS 14.0, watchOS 7.0, *)
    final class Delegate: NSObject, CLLocationManagerDelegate{
        
        /// Continuation asynchronously passing location data
        var stream: Streaming?{
            didSet {
                stream?.onTermination = { @Sendable [weak self] termination in
                    self?.onTermination(termination)
                }
            }
        }
        
        // MARK: - Delegate
        
        
        /// Stop streaming
        public func finish(){
            stream?.finish()
        }
        
        /// Pass `CLLocation` into the async stream
        /// - Parameters:
        ///   - manager: Location manager
        ///   - locations: Array of `CLLocation`
        public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
                locations.forEach{ pass(location: $0) }
        }
        
        /// Notify about location manager changed authorization status
        /// - Parameter manager: Location manager
        public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
            NotificationCenter.default.post(name: Permission.authorizationStatus, object: manager.authorizationStatus)
        }
        
        
        /// Tells the delegate that the location manager was unable to retrieve a location value
        /// - Parameters:
        ///   - manager: The location manager object that was unable to retrieve the location
        ///   - error: The error object containing the reason the location or heading could not be retrieved
        func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
            guard let e = error as? CLError else{ return }

                if e.code == CLError.locationUnknown{
                    return /// glitch throwing this error on some devices and simulator while changing locations time by time
                }
              
                let type = AsyncLocationErrors.self
                stream?.finish(throwing: type.coreLocationManagerError(e))
        }
        
        // MARK: - Private
        
        /// Process termination
        /// - Parameter termination: A type that indicates how the stream terminated.
        private func onTermination(_ termination: Termination){
            let type = AsyncLocationErrors.self
            switch(termination){
            case .finished(_) : fallthrough
            case .cancelled: stream?.finish(throwing: type.streamCanceled)
            @unknown default:
                stream?.finish(throwing: type.streamUnknownTermination)
            }
            
            stream = nil
         }
        
        /// Passing ``CLLocation`` data
        /// - Parameter location: Location data
        private func pass(location : CLLocation){
            stream?.yield(location)
        }
        
    }
    
    // MARK: - Alias types -

    private typealias Termination = AsyncThrowingStream<CLLocation, Error>.Continuation.Termination
    
    typealias Streaming = AsyncThrowingStream<CLLocation, Error>.Continuation
    
}
