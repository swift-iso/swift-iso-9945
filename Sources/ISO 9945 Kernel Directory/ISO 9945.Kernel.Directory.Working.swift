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

// MARK: - POSIX getcwd() syscall

extension ISO_9945.Kernel.Directory.Working {
    /// Fills the provided buffer with the current working directory path.
    ///
    /// Low-level variant for callers that want to manage their own buffer.
    ///
    /// - Parameter buffer: Buffer to fill with the path. Must be large enough
    ///   to hold the path including null terminator.
    /// - Returns: Length of the path written (excluding null terminator).
    /// - Throws: ``Error`` on failure.
    public static func current(
        into buffer: UnsafeMutableBufferPointer<CChar>
    ) throws(Error) -> Int {
        guard let base = buffer.baseAddress, buffer.count > 0 else {
            throw .platform(Error_Primitives.Error(code: .posix(EINVAL)))
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.getcwd(base, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.getcwd(base, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.getcwd(base, buffer.count)
        #endif

        guard unsafe (result != nil) else {
            throw Kernel.Directory.Working.Error.current()
        }

        // Find null terminator to get length
        var length = 0
        while length < buffer.count && (unsafe base[length]) != 0 {
            length += 1
        }

        return length
    }
}

// MARK: - Borrow-First APIs

extension ISO_9945.Kernel.Directory.Working {

    /// Canonical primitive: scoped access to current working directory bytes.
    ///
    /// This is the most primitive API. It provides zero-copy access to the
    /// raw bytes returned by `getcwd(2)`. The closure receives a `Span`
    /// that does NOT include the NUL terminator.
    ///
    /// - Parameter body: A closure that processes the path bytes. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: ``Error`` on syscall failure.
    public static func withCurrentBytes<R: ~Copyable>(
        _ body: (Span<Path.Char>) -> R
    ) throws(Error) -> R {
        var result: R? = nil
        var thrown: Error? = nil

        unsafe Swift.withUnsafeTemporaryAllocation(of: CChar.self, capacity: 4096) { buffer in
            guard let base = buffer.baseAddress, buffer.count > 0 else {
                thrown = .platform(Error_Primitives.Error(code: .posix(EINVAL)))
                return
            }

            #if canImport(Darwin)
                let cwdResult = unsafe Darwin.getcwd(base, buffer.count)
            #elseif canImport(Musl)
                let cwdResult = unsafe Musl.getcwd(base, buffer.count)
            #elseif canImport(Glibc)
                let cwdResult = unsafe Glibc.getcwd(base, buffer.count)
            #endif

            guard unsafe (cwdResult != nil) else {
                thrown = Kernel.Directory.Working.Error.current()
                return
            }

            // Find null terminator to get length
            var length = 0
            while length < buffer.count && (unsafe base[length]) != 0 {
                length += 1
            }

            let u8Ptr = unsafe UnsafePointer<UInt8>(base)
            let span = unsafe Span(_unsafeStart: u8Ptr, count: length)
            result = body(span)
        }

        if let thrown { throw thrown }
        return result!
    }

    /// Convenience: scoped access as NUL-terminated view.
    ///
    /// This API provides a `String.Borrowed` for APIs that expect
    /// NUL-terminated strings. The underlying buffer already includes
    /// the NUL terminator from `getcwd(2)`.
    ///
    /// - Parameter body: A closure that processes the path view. Non-throwing.
    /// - Returns: The result of the closure.
    /// - Throws: ``Error`` on syscall failure.
    public static func withCurrent<R: ~Copyable>(
        _ body: (borrowing String.Borrowed) -> R
    ) throws(Error) -> R {
        var result: R? = nil
        var thrown: Error? = nil

        unsafe Swift.withUnsafeTemporaryAllocation(of: CChar.self, capacity: 4096) { buffer in
            guard let base = buffer.baseAddress, buffer.count > 0 else {
                thrown = .platform(Error_Primitives.Error(code: .posix(EINVAL)))
                return
            }

            #if canImport(Darwin)
                let cwdResult = unsafe Darwin.getcwd(base, buffer.count)
            #elseif canImport(Musl)
                let cwdResult = unsafe Musl.getcwd(base, buffer.count)
            #elseif canImport(Glibc)
                let cwdResult = unsafe Glibc.getcwd(base, buffer.count)
            #endif

            guard unsafe (cwdResult != nil) else {
                thrown = Kernel.Directory.Working.Error.current()
                return
            }

            // getcwd NUL-terminates; create view directly
            let u8Ptr = unsafe UnsafePointer<UInt8>(base)
            let view = unsafe String.Borrowed(u8Ptr, count: String.length(of: u8Ptr))
            result = body(view)
        }

        if let thrown { throw thrown }
        return result!
    }

    /// Owned convenience: returns allocated string.
    ///
    /// This is the simplest API but involves allocation. For callers that
    /// need to transform the result (e.g., into a `File.Path`), prefer
    /// `withCurrentBytes` or `withCurrent` to avoid intermediate allocations.
    ///
    /// ## Errors
    /// - `.path(.notFound)`: Directory has been deleted
    /// - `.permission`: Search permission denied for a component
    ///
    /// - Returns: The absolute path of the current working directory.
    /// - Throws: ``Error`` on failure.
    public static func current() throws(Error) -> String {
        try withCurrent { view in
            String(copying: view)
        }
    }
}

// MARK: - Error Conversion

extension ISO_9945.Kernel.Directory.Working.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let pathError = Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
