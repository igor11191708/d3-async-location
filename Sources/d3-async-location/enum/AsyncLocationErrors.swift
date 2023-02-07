//
//  LocationManagerErrors.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import Foundation

/// Async locations manager errors
@available(iOS 15.0, watchOS 7.0, *)
public enum AsyncLocationErrors: Error{
   
    ///Access was denied by  user
    case accessIsNotAuthorized
    
    /// Attempt to launch streaming while it's been already started
    /// Subscribe different Views to LMViewModel.locations publisher to feed them
    case streamingProcessHasAlreadyStarted
    
    /// Stream was cancelled or terminated
    case streamTerminated

}
