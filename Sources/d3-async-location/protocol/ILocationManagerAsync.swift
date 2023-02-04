//
//  File.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import Foundation
import CoreLocation

protocol ILocationManagerAsync{
    
    /// Check status and get stream of async data
    var start : AsyncThrowingStream<CLLocation, Error> { get async throws }
    
    /// Stop streaming
    func stop()
}
