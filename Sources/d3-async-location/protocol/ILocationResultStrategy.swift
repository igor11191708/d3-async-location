//
//  ILocationResultStrategy.swift
//  d3-async-location
//
//  Created by Igor  on 11.12.24.
//

/// A protocol that defines a strategy for processing location results.
/// Implementations of this protocol determine how new location results are handled
/// (e.g., whether they replace the previous results or are appended).
@available(iOS 14.0, watchOS 7.0, *)
public protocol ILocationResultStrategy {
    
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
