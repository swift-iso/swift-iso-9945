// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

/// Terminal.Stream overloads for ISO_9945.Kernel.IO.Write.
///
/// Standard streams (stdin/stdout/stderr) are process-owned file descriptors
/// that cannot be wrapped in `ISO_9945.Kernel.Descriptor` without claiming
/// ownership (which would close them on deinit). These overloads accept
/// `Terminal.Stream` directly, performing the raw fd extraction at the C
/// boundary per [IMPL-010].

#if !os(Windows)

    #if canImport(Darwin)
        internal import Darwin
    #elseif canImport(Glibc)
        internal import Glibc
    #elseif canImport(Musl)
        internal import Musl
    #endif

    extension ISO_9945.Kernel.IO.Write {
        /// Writes bytes to a terminal stream.
        ///
        /// Single raw `write(2)` invocation. Does NOT loop on partial writes; does
        /// NOT retry on EINTR. The high-level `Terminal.Stream.Write.callAsFunction`
        /// composes this with a partial-write + EINTR-retry loop suitable for
        /// terminal output.
        ///
        /// - Parameters:
        ///   - stream: The terminal stream to write to.
        ///   - buffer: The buffer to write from.
        /// - Returns: Number of bytes written (may be less than `buffer.count`).
        /// - Throws: `ISO_9945.Kernel.IO.Write.Error` on failure (including EINTR).
        public static func write(
            _ stream: Terminal.Stream,
            from buffer: UnsafeRawBufferPointer
        ) throws(Error) -> Int {
            guard let baseAddress = buffer.baseAddress else {
                return 0
            }
            #if canImport(Darwin)
                return try Syscall.require(
                    unsafe Darwin.write(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Musl)
                return try Syscall.require(
                    unsafe Musl.write(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #elseif canImport(Glibc)
                return try Syscall.require(
                    unsafe Glibc.write(stream.rawValue, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        }
    }

    // MARK: - Error Conversion

    extension ISO_9945.Kernel.IO.Write.Error {
        /// Creates an error from the current errno value.
        fileprivate static func current() -> Self {
            let code = Error_Primitives.Error.Code.current()
            if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
                return .handle(handleError)
            }
            if let blockingError = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
                return .blocking(blockingError)
            }
            return .platform(Error_Primitives.Error(code: code))
        }
    }

#endif
