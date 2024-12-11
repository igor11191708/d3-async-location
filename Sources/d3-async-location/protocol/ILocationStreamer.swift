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
public protocol ILocationStreamer{
        
    /// List of locations
    var results : [LocationStreamer.Output] { get }
    
    /// Strategy for publishing locations Default value is .keepLast
    var strategy : ILocationResultStrategy { get }
    
    /// Start streaming locations
    func start(clean: Bool) async throws
    
    /// Stop streaming locations
    func stop()
}
