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
   
    func start() -> AsyncStream<LocationStreamer.Output>
    
    /// Stop streaming
    func finish()
    
    func permission() async throws
}
