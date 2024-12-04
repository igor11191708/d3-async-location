//
//  AsyncFIFOQueue.swift
//  d3-async-location
//
//  Created by Igor Shelopaev on 04.12.24.
//

import Foundation

/// A generic FIFO queue that provides an asynchronous stream of elements.
/// The stream is initialized lazily and can be terminated and cleaned up.
class AsyncFIFOQueue<Element> {
    
    /// The asynchronous stream that consumers can iterate over.
    private var stream: AsyncStream<Element>?
    
    /// The continuation used to produce values for the stream.
    private var continuation: AsyncStream<Element>.Continuation?
    
    /// Initializes the FIFO queue without creating the stream immediately.
    init() {
        // Stream and continuation are initialized lazily.
    }
    
    /// Initializes the stream and continuation.
    /// Should be called before starting to enqueue elements.
    /// - Parameter onTermination: An escaping closure to handle termination events.
    /// - Returns: The initialized `AsyncStream<Element>`.
    func initializeStream(onTermination: @escaping (AsyncStream<Element>.Continuation.Termination) -> Void) -> AsyncStream<Element> {

        if let existingStream = stream {
            return existingStream
        }
        
        let (newStream, newContinuation) = AsyncStream<Element>.makeStream(of: Element.self)
        
        newContinuation.onTermination = { [weak self] termination in
            onTermination(termination)
            self?.finish()
        }
        
        // Store the stream and continuation.
        self.stream = newStream
        self.continuation = newContinuation
        
        return newStream
    }
    
    /// Provides access to the asynchronous stream.
    /// - Returns: The initialized `AsyncStream<Element>` instance, or `nil` if not initialized.
    func getStream() -> AsyncStream<Element>? {
        return stream
    }
    
    /// Enqueues a new element into the stream.
    /// - Parameter element: The element to enqueue.
    func enqueue(_ element: Element) {
        continuation?.yield(element)
    }
    
    /// Finishes the stream, indicating no more elements will be enqueued.
    /// Cleans up the stream and continuation.
    func finish() {
        continuation?.finish()
        continuation = nil
        stream = nil
    }
}
