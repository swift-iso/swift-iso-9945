// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if !os(Windows)

    // MARK: - POSIX Error Code Mapping

    extension ISO_9945.Kernel.Lock.Error {
        /// Creates a lock error from a POSIX error code, if applicable.
        ///
        /// - Parameter code: The kernel error code.
        /// - Returns: A lock error, or `nil` if not applicable.
        @inlinable
        public init?(code: Error_Primitives.Error.Code) {
            if code == Error_Primitives.Error.Code.POSIX.EAGAIN || code == Error_Primitives.Error.Code.POSIX.EACCES {
                // POSIX.1-2017 specifies the fcntl F_SETLK held-lock failure
                // as "[EACCES] or [EAGAIN]"; both mean contention here.
                self = .contention
            } else if code == Error_Primitives.Error.Code.POSIX.EDEADLK {
                self = .deadlock
            } else if code == Error_Primitives.Error.Code.POSIX.ENOLCK {
                self = .unavailable
            } else if code == Error_Primitives.Error.Code.POSIX.EINTR {
                self = .interrupted
            } else {
                return nil
            }
        }
    }

#endif
