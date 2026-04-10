// ISO 9945.Kernel.Lock.Scope.Error.swift
// swift-iso-9945

extension ISO_9945.Kernel.Lock.Scope {
    /// Error thrown by scoped locking helpers.
    public enum Error<E: Swift.Error>: Swift.Error, Sendable {
        /// Lock acquisition or release failed.
        case lock(Kernel.Lock.Error)
        /// The body closure threw an error.
        case body(E)
    }
}
