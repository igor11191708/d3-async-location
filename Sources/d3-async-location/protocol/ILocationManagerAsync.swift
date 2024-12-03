//
//  File.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import Foundation
import CoreLocation

@available(iOS 14.0, watchOS 7.0, *)
protocol ILocationManagerAsync {
    
    /// Starts the async stream of location updates.
    /// - Returns: An `AsyncStream` of `Output` that emits location updates or errors.
    /// - Throws: An error if the streaming cannot be started.
    func start() async throws -> AsyncStream<LMViewModel.Output>
    
    /// Stops the location streaming process.
    func stop()
}
