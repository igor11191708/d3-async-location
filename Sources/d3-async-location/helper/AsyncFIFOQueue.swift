//
//  AsyncFIFOQueue.swift
//  d3-async-location
//
//  Created by Igor Shelopaev on 04.12.24.
//

import Foundation

extension LocationManager {
    
    /// A generic FIFO queue that provides an asynchronous stream of elements.
    /// The stream is initialized lazily and can be terminated and cleaned up.
    @available(iOS 14.0, watchOS 7.0, *)
    final class AsyncFIFOQueue<Element: Sendable>: @unchecked Sendable {
        
        /// Type alias for the AsyncStream Continuation.
        typealias Continuation = AsyncStream<Element>.Continuation
        
        /// Type alias for the termination handler closure.
        typealias TerminationHandler = @Sendable (Continuation.Termination) -> Void
        
        /// The asynchronous stream that consumers can iterate over.
        private var stream: AsyncStream<Element>?
        
        /// The continuation used to produce values for the stream.
        private var continuation: Continuation?
        
        /// Initializes the stream and continuation.
        /// Should be called before starting to enqueue elements.
        /// - Parameter onTermination: An escaping closure to handle termination events.
        /// - Returns: The initialized `AsyncStream<Element>`.
        func initializeQueue(onTermination: @escaping TerminationHandler) -> AsyncStream<Element> {
            // Return the existing stream if it's already initialized.
            if let existingStream = stream {
                return existingStream
            }
            
            let (newStream, newContinuation) = AsyncStream<Element>.makeStream(of: Element.self)
            
            newContinuation.onTermination = { [weak self] termination in
                onTermination(termination)
                self?.finish()
            }
            
            self.stream = newStream
            self.continuation = newContinuation
            
            return newStream
        }
        
        /// Provides access to the asynchronous stream.
        /// - Returns: The initialized `AsyncStream<Element>` instance, or `nil` if not initialized.
        func getQueue() -> AsyncStream<Element>? {
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
}
