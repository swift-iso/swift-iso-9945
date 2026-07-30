// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Kernel.Thread {
    /// Errors from thread operations.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// Thread creation failed.
        ///
        /// - On POSIX: The return value from `pthread_create` (e.g., EAGAIN, EPERM).
        /// - On Windows: The value from `GetLastError()`.
        case create(Error_Primitives.Error.Code)

        /// Thread join failed.
        case join(Error_Primitives.Error.Code)

        /// Thread detach failed.
        case detach(Error_Primitives.Error.Code)

        /// Thread-local storage key creation failed (`pthread_key_create`).
        ///
        /// `EAGAIN` (`PTHREAD_KEYS_MAX` exhausted) or `ENOMEM`.
        case keyCreate(Error_Primitives.Error.Code)

        /// Thread-local storage slot write failed (`pthread_setspecific`).
        case keySet(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.Thread.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .create(let code):
            return "Thread creation failed: \(code)"
        case .join(let code):
            return "Thread join failed: \(code)"
        case .detach(let code):
            return "Thread detach failed: \(code)"
        case .keyCreate(let code):
            return "Thread-local storage key creation failed: \(code)"
        case .keySet(let code):
            return "Thread-local storage slot write failed: \(code)"
        }
    }
}
