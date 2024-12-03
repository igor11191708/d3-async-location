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
}


@available(iOS 14.0, watchOS 7.0, *)
extension AsyncLocationErrors: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .accessIsNotAuthorized:
            return NSLocalizedString("Access was denied by the user.", comment: "")
        }
    }
}
