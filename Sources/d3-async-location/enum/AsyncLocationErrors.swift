//
//  LocationManagerErrors.swift
//  
//
//  Created by Igor on 03.02.2023.
//

import CoreLocation

/// Async locations manager errors
@available(iOS 14.0, watchOS 7.0, *)
public enum AsyncLocationErrors: Error{
   
    ///Access was denied by  user
    case accessIsNotAuthorized
    
    /// Attempt to launch streaming while it's been already started
    /// Subscribe different Views to LMViewModel.locations publisher to feed them
    case streamingProcessHasAlreadyStarted
    
    /// Stream was cancelled or terminated
    case streamCanceled

    /// Stream was cancelled or terminated
    case streamUnknownTermination
    
    /// A Core Location error
    case coreLocationManagerError(CLError)
    
}


@available(iOS 14.0, watchOS 7.0, *)
extension AsyncLocationErrors: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .accessIsNotAuthorized:
            return NSLocalizedString("Access was denied by the user.", comment: "")

        case .streamingProcessHasAlreadyStarted:
            return NSLocalizedString("Attempted to start streaming while it's already running.", comment: "")

        case .streamCanceled:
            return NSLocalizedString("The stream was cancelled or terminated.", comment: "")

        case .streamUnknownTermination:
            return NSLocalizedString("The stream was cancelled or terminated due to an unknown error.", comment: "")

        case .coreLocationManagerError(let error):
            return error.localizedDescription
        }
    }
}
