// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-loader open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-loader project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import Loader_Primitives
public import ISO_9945  // For ISO_9945.Loader typealias

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Implementation

#if !os(Windows)

extension ISO_9945.Loader.Library {
    /// Opens a dynamic library (POSIX).
    ///
    /// Wraps `dlopen` on POSIX systems.
    ///
    /// - Parameters:
    ///   - path: Path to the library, or `nil` for the main executable.
    ///   - options: Loading options. Default: `.now` (fail-early).
    /// - Returns: Handle to the loaded library.
    /// - Throws: `Loader.Error.open` with dlerror message.
    @unsafe
    public static func open(
        path: UnsafePointer<CChar>?,
        options: Options = .now
    ) throws(Loader.Error) -> Handle {
        // Clear stale error
        _ = unsafe dlerror()

        guard let handle = unsafe dlopen(path, options.rawValue) else {
            throw .open(ISO_9945.Loader.Error.captureError())
        }
        return unsafe Handle(rawValue: handle)
    }

    /// Closes a dynamic library (POSIX).
    ///
    /// Wraps `dlclose` on POSIX systems.
    ///
    /// - Parameter handle: The library handle to close.
    /// - Throws: `Loader.Error.close` on failure.
    @unsafe
    public static func close(_ handle: Handle) throws(Loader.Error) {
        // Clear stale error
        _ = unsafe dlerror()

        guard unsafe dlclose(handle.rawValue) == 0 else {
            throw .close(ISO_9945.Loader.Error.captureError())
        }
    }
}

#endif
