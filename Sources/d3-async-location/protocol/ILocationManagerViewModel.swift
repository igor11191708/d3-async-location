//
//  ILocationManagerViewModel.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation
import SwiftUI

@available(iOS 14.0, watchOS 7.0, *)
@MainActor
public protocol ILocationManagerViewModel{
        
    /// List of locations
    var results : [LocationStreamer.Output] { get }
    
    /// Strategy for publishing locations Default value is .keepLast
    var strategy : LocationStreamer.Strategy { get }
    
    /// Start streaming locations
    func start() async throws
    
    /// Stop streaming locations
    func stop()
}
