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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error_Primitives.Error.Code {
    /// Returns the platform error message for a POSIX error code.
    ///
    /// Calls `strerror_r()` (ISO 9945 / POSIX.1) into a caller-owned buffer
    /// for `.posix` codes, so concurrent callers cannot observe each other's
    /// text. POSIX does not require `strerror()` to be thread-safe.
    /// Returns `nil` for `.win32` codes and when the platform reports no
    /// message for the code.
    public var posixMessage: Swift.String? {
        switch self {
        case .posix(let rawValue):
            var buffer = [CChar](repeating: 0, count: 256)
            #if canImport(Glibc)
                // glibc exposes the GNU variant: returns a pointer to the
                // message, which may be the supplied buffer or a static
                // immutable string; either is safe to read here.
                let message = unsafe strerror_r(rawValue, &buffer, buffer.count)
                return unsafe message.map { unsafe Swift.String(cString: $0) }
            #else
                // XSI variant: fills the supplied buffer and returns 0 on
                // success.
                let result = unsafe strerror_r(rawValue, &buffer, buffer.count)
                guard result == 0 else { return nil }
                return unsafe buffer.withUnsafeBufferPointer { unsafe Swift.String(cString: $0.baseAddress!) }
            #endif
        case .win32:
            return nil
        }
    }
}
