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

#if !os(Windows)

public import Kernel_File_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Kernel.File {
    /// File access pattern advice for `posix_fadvise(2)`.
    ///
    /// Covers the six POSIX.1-2001 access-pattern hints. Platform-specific
    /// extensions (e.g., Linux-only variants) may add further constants on
    /// top of this shell in their respective L2 packages.
    public struct Advice: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

// MARK: - POSIX Constants
//
// POSIX_FADV_* are declared in <fcntl.h> on Linux-family and BSD platforms.
// Darwin's fcntl.h does not ship the full POSIX.1-2001 set (notably
// POSIX_FADV_NOREUSE is absent), so the whole constant block is gated
// here to match the platforms that actually define the symbols. Darwin
// may extend Kernel.File.Advice with its own subset separately when a
// need arises.

#if os(Linux) || os(Android) || os(OpenBSD)

extension Kernel.File.Advice {
    /// No special treatment (default).
    public static let normal = Self(rawValue: UInt32(POSIX_FADV_NORMAL))

    /// Expect random access.
    public static let random = Self(rawValue: UInt32(POSIX_FADV_RANDOM))

    /// Expect sequential access.
    public static let sequential = Self(rawValue: UInt32(POSIX_FADV_SEQUENTIAL))

    /// Data will be accessed in the near future.
    public static let willNeed = Self(rawValue: UInt32(POSIX_FADV_WILLNEED))

    /// Data will not be accessed in the near future.
    public static let dontNeed = Self(rawValue: UInt32(POSIX_FADV_DONTNEED))

    /// Data will be accessed only once.
    public static let noReuse = Self(rawValue: UInt32(POSIX_FADV_NOREUSE))
}

#endif

#endif
