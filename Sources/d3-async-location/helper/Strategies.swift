//
//  Strategies.swift
//
//
//  Created by Igor Shelopaev on 10.02.2023.
//

import Foundation



/// A concrete strategy that keeps only the last location result.
/// This strategy ensures that only the most recent location update is retained.
@available(iOS 14.0, watchOS 7.0, *)
public struct KeepLastStrategy: ILocationResultStrategy {
    
    /// Initializes a new instance of `KeepLastStrategy`.
    public init() {}
    
    /// Processes the results array by replacing it with the new result.
    /// - Parameters:
    ///   - results: The current array of processed results (ignored in this strategy).
    ///   - newResult: The new result to be stored.
    /// - Returns: An array containing only the new result.
    public func process(results: [Output], newResult: Output) -> [Output] {
        return [newResult]
    }
}

/// A concrete strategy that keeps all location results.
/// This strategy appends each new location result to the existing array.
@available(iOS 14.0, watchOS 7.0, *)
public struct KeepAllStrategy: ILocationResultStrategy {
    
    /// Initializes a new instance of `KeepAllStrategy`.
    public init() {}
    
    /// Processes the results array by appending the new result to it.
    /// - Parameters:
    ///   - results: The current array of processed results.
    ///   - newResult: The new result to be added to the array.
    /// - Returns: A new array of results, including the new result appended to the existing results.
    public func process(results: [Output], newResult: Output) -> [Output] {
        var updatedResults = results
        updatedResults.append(newResult)
        return updatedResults
    }
}
