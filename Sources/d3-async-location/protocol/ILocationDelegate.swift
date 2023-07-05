//
//  ILocationDelegate.swift
//  
//
//  Created by Igor on 05.07.2023.
//

import Foundation
import CoreLocation

@available(iOS 14.0, watchOS 7.0, *)
public protocol ILocationDelegate: NSObjectProtocol, CLLocationManagerDelegate{
    
    var stream: AsyncThrowingStream<CLLocation, Error>.Continuation? {get set}
    
    /// Set stream
    /// - Parameter continuation: Continuation passing location data
    func setStream(with continuation : AsyncThrowingStream<CLLocation, Error>.Continuation)
    
    /// Stop streaming
    func finish()
}

extension ILocationDelegate{
    
    /// Set stream
    /// - Parameter continuation: Continuation passing location data
    public func setStream(with continuation : AsyncThrowingStream<CLLocation, Error>.Continuation){
        stream = continuation
    }
    
    /// Stop streaming
    public func finish(){
        stream?.finish()
        stream = nil
    }
}
