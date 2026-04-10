// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - Major/Minor Extraction

extension ISO_9945.Kernel.Device {
    /// The major device number (identifies device type/driver).
    ///
    /// This uses the standard Linux encoding for dev_t.

    public var major: Major {
        Major(rawValue: UInt32((rawValue >> 8) & 0xFFF))
    }

    /// The minor device number (identifies specific device instance).
    ///
    /// This uses the standard Linux encoding for dev_t.

    public var minor: Minor {
        Minor(rawValue: UInt32((rawValue & 0xFF) | ((rawValue >> 12) & 0xFFF00)))
    }

    /// Creates a device ID from raw major and minor numbers.

    internal init(major: UInt32, minor: UInt32) {
        let majorPart = UInt64(major & 0xFFF) << 8
        let minorLow = UInt64(minor & 0xFF)
        let minorHigh = UInt64((minor & 0xFFF00)) << 12
        self.init(rawValue: majorPart | minorLow | minorHigh)
    }
}

// MARK: - Typed Accessors

extension ISO_9945.Kernel.Device {
    /// Creates a device ID from typed major and minor numbers.
    public init(major: Major, minor: Minor) {
        self.init(major: major.rawValue, minor: minor.rawValue)
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Device: @retroactive CustomStringConvertible {
    /// Returns "major:minor" format for POSIX device IDs.
    public var description: Swift.String {
        "\(major):\(minor)"
    }
}
