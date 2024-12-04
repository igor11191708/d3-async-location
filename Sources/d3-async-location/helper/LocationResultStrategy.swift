//
//  Strategy.swift
//  
//
//  Created by Igor Shelopaev on 10.02.2023.
//

import Foundation

/// A protocol that defines a strategy for processing location results.
/// Implementations of this protocol determine how new location results are handled
/// (e.g., whether they replace the previous results or are appended).
@available(iOS 14.0, watchOS 7.0, *)
public protocol LocationResultStrategy {
    
    /// The type of output that the strategy processes.
    /// `Output` is defined as `LocationStreamer.Output`, which is a `Result` containing
    /// an array of `CLLocation` objects or a `CLError`.
    typealias Output = LocationStreamer.Output
    
    /// Processes the results array by incorporating a new location result.
    /// - Parameters:
    ///   - results: The current array of processed results.
    ///   - newResult: The new result to be processed and added.
    /// - Returns: A new array of results after applying the strategy.
    func process(results: [Output], newResult: Output) -> [Output]
}

/// A concrete strategy that keeps only the last location result.
/// This strategy ensures that only the most recent location update is retained.
@available(iOS 14.0, watchOS 7.0, *)
public struct KeepLastStrategy: LocationResultStrategy {
    
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
public struct KeepAllStrategy: LocationResultStrategy {
    
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
