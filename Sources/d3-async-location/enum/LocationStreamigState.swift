//
//  LocationStreamigState.swift
//  
//
//  Created by Igor on 04.02.2023.
//

import Foundation

/// Streaming states
@available(iOS 14.0, watchOS 7.0, *)
enum LocationStreamingState{
    
    /// not streaming
    case idle    
   
    /// streaming has been started
    case streaming
}
