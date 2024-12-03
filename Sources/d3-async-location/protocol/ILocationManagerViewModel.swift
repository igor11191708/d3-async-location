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
public protocol ILocationManagerViewModel: ObservableObject{
        
    /// List of locations
    var results : [LMViewModel.Output] { get }
    
    /// Strategy for publishing locations Default value is .keepLast
    var strategy : LMViewModel.Strategy { get }
    
    /// Start streaming locations
    func start() async throws
    
    /// Stop streaming locations
    func stop()
}
