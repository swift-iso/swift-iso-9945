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
public import POSIX_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension POSIX.Loader {
    /// POSIX dynamic library operations.
    ///
    /// Wraps `dlopen`/`dlclose` on POSIX systems.
    public enum Library: Sendable {}
}

// MARK: - Handle Alias

extension POSIX.Loader.Library {
    /// Library handle type.
    ///
    /// Aliases to `Loader.Library.Handle` from swift-loader-primitives.
    public typealias Handle = Loader.Library.Handle
}

// MARK: - POSIX Implementation

#if !os(Windows)

extension POSIX.Loader.Library {
    /// Opens a dynamic library.
    ///
    /// - Parameters:
    ///   - path: Path to the library, or `nil` for the main executable.
    ///   - options: Loading options. Default: `.now` (fail-early).
    /// - Returns: Handle to the loaded library.
    /// - Throws: `Loader.Error.open` with dlerror message.
    @inlinable
    public static func open(
        path: UnsafePointer<CChar>?,
        options: Options = .now
    ) throws(Loader.Error) -> Handle {
        // Clear stale error
        _ = dlerror()

        guard let handle = dlopen(path, options.rawValue) else {
            throw .open(POSIX.Loader.captureError())
        }
        return Handle(rawValue: handle)
    }

    /// Closes a dynamic library.
    ///
    /// - Parameter handle: The library handle to close.
    /// - Throws: `Loader.Error.close` on failure.
    @inlinable
    public static func close(_ handle: Handle) throws(Loader.Error) {
        // Clear stale error
        _ = dlerror()

        guard dlclose(handle.rawValue) == 0 else {
            throw .close(POSIX.Loader.captureError())
        }
    }
}

#endif
