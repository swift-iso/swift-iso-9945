// ISO 9945.Kernel.Lock.WithLockError.swift
// swift-iso-9945

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

extension ISO_9945.Kernel.Lock {
    /// Error thrown by scoped locking helpers.
    public enum WithLockError<E: Swift.Error>: Swift.Error, Sendable {
        /// Lock acquisition or release failed.
        case lock(Kernel.Lock.Error)
        /// The body closure threw an error.
        case body(E)
    }
}
