//
//  File.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import Foundation
import CoreLocation

protocol ILocationManagerAsync: CLLocationManagerDelegate{
    
    /// Check status and get stream of async data
    var start : AsyncStream<CLLocation> { get async throws }
    
    /// Stop streaming
    func stop()
}
