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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX getcwd() syscall

extension ISO_9945.Kernel.Directory.Working {
    /// Returns the current working directory as a String.
    ///
    /// ## Errors
    /// - `.path(.notFound)`: Directory has been deleted
    /// - `.permission`: Search permission denied for a component
    ///
    /// - Returns: The absolute path of the current working directory.
    /// - Throws: ``Error`` on failure.
    public static func current() throws(Error) -> String {
        // Start with reasonable buffer size, grow if needed
        var bufferSize = 1024

        while true {
            var buffer = [CChar](repeating: 0, count: bufferSize)

            #if canImport(Darwin)
                let result = Darwin.getcwd(&buffer, bufferSize)
            #elseif canImport(Musl)
                let result = Musl.getcwd(&buffer, bufferSize)
            #elseif canImport(Glibc)
                let result = Glibc.getcwd(&buffer, bufferSize)
            #endif

            if result != nil {
                // Find null terminator and decode
                let length = buffer.firstIndex(of: 0) ?? buffer.count
                return String(decoding: buffer[..<length].map { UInt8(bitPattern: $0) }, as: UTF8.self)
            }

            let code = Kernel.Error.Code.posix(errno)

            // ERANGE means buffer too small, double and retry
            if code.posix == ERANGE {
                bufferSize *= 2
                // Sanity check - PATH_MAX is typically 4096
                if bufferSize > 65536 {
                    throw .platform(Kernel.Error(code: code))
                }
                continue
            }

            throw Kernel.Directory.Working.Error.fromPosixErrno(code)
        }
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
            let result = Darwin.getcwd(base, buffer.count)
        #elseif canImport(Musl)
            let result = Musl.getcwd(base, buffer.count)
        #elseif canImport(Glibc)
            let result = Glibc.getcwd(base, buffer.count)
        #endif

        guard result != nil else {
            throw Kernel.Directory.Working.Error.current()
        }

        // Find null terminator to get length
        var length = 0
        while length < buffer.count && base[length] != 0 {
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
