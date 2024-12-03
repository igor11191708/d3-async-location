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
    
    var continuation: AsyncStream<LMViewModel.Output>.Continuation? {get set}
   
    /// Stop streaming
    func finish()
    
    func permission() async throws
}
