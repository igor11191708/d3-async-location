//
//  ILocationManagerViewModel.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation
import SwiftUI

@available(iOS 15.0, *)
public protocol ILocationManagerViewModel: ObservableObject{
        
    /// List of locations
    @MainActor
    var locations : [CLLocation] { get }
    
    /// Start streaming locations
    func start() async throws
    
    /// Stop streaming locations
    func stop() async
}
