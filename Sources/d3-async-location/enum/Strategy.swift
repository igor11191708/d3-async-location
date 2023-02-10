//
//  Strategy.swift
//  
//
//  Created by Igor on 10.02.2023.
//

import Foundation

@available(iOS 14.0, watchOS 7.0, *)
public extension LMViewModel{
    
    /// Strategy for publishing locations
     enum Strategy{
         
        case keepAll
         
        case keepLast
         
         /// Check if the strategy keep all streamed values
         var isKeepLast: Bool{
             self == .keepLast
         }
         
         /// Check if the strategy keep only the last one
         var isKeepAll: Bool{
             self == .keepAll
         }
         
    }
}
