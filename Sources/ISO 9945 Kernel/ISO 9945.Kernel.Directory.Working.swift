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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945
internal import ISO_9945_ABI

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX getcwd() syscall

extension ISO_9945.Kernel.Directory.Working {
    /// Returns the current working directory as a `Kernel.String`.
    ///
    /// ## Errors
    /// - `.path(.notFound)`: Directory has been deleted
    /// - `.permission`: Search permission denied for a component
    ///
    /// - Returns: The absolute path of the current working directory.
    /// - Throws: ``Error`` on failure.
    public static func current() throws(Error) -> Kernel.String {
        var out: Kernel.String? = nil
        var thrown: Error? = nil

        Swift.withUnsafeTemporaryAllocation(of: CChar.self, capacity: 4096) { buffer in
            guard let base = buffer.baseAddress, buffer.count > 0 else {
                thrown = .platform(Kernel.Error(code: .posix(EINVAL)))
                return
            }

            #if canImport(Darwin)
                let result = unsafe Darwin.getcwd(base, buffer.count)
            #elseif canImport(Musl)
                let result = unsafe Musl.getcwd(base, buffer.count)
            #elseif canImport(Glibc)
                let result = unsafe Glibc.getcwd(base, buffer.count)
            #endif

            guard result != nil else {
                thrown = Kernel.Directory.Working.Error.current()
                return
            }

            // getcwd NUL-terminates; project and copy
            let u8Ptr = unsafe UnsafePointer<UInt8>(base)
            let view = unsafe Kernel.String.View(u8Ptr)
            out = unsafe Kernel.String(copying: view)
        }

        if let thrown { throw thrown }
        return unsafe out!
    }

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
            throw .platform(Kernel.Error(code: .posix(EINVAL)))
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.getcwd(base, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.getcwd(base, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.getcwd(base, buffer.count)
        #endif

        guard result != nil else {
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

// MARK: - Error Conversion

extension Kernel.Directory.Working.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        fromPosixErrno(.posix(errno))
    }

    /// Creates an error from a POSIX error code.
    internal static func fromPosixErrno(_ code: Kernel.Error.Code) -> Self {
        if let pathError = Kernel.Path.Resolution.Error(code: code) {
            return .path(pathError)
        }
        if let permError = Kernel.Permission.Error(code: code) {
            return .permission(permError)
        }
        return .platform(Kernel.Error(code: code))
    }
}
