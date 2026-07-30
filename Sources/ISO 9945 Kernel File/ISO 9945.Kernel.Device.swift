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

#if canImport(CISO9945Shim)
    internal import CISO9945Shim

    // MARK: - Major/Minor Extraction

    extension ISO_9945.Kernel.Device {
        /// The major device number (identifies device type/driver).
        ///
        /// POSIX defines no `dev_t` encoding; the decomposition is a
        /// platform mechanism. This uses the platform's own `major()`
        /// macro via the C shim, so the value is correct and lossless on
        /// every supported platform.
        public var major: Major {
            Major(rawValue: UInt32(iso9945_device_major(rawValue)))
        }

        /// The minor device number (identifies specific device instance).
        ///
        /// Uses the platform's own `minor()` macro via the C shim.
        public var minor: Minor {
            Minor(rawValue: UInt32(iso9945_device_minor(rawValue)))
        }

        /// Creates a device ID from raw major and minor numbers.
        ///
        /// Uses the platform's own `makedev()` macro via the C shim, so
        /// `Device(major: m, minor: n)` round-trips losslessly through
        /// `major`/`minor`.
        internal init(major: UInt32, minor: UInt32) {
            self.init(rawValue: iso9945_device_make(major, minor))
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

    extension ISO_9945.Kernel.Device: CustomStringConvertible {
        /// Returns "major:minor" format for POSIX device IDs.
        public var description: Swift.String {
            "\(major):\(minor)"
        }
    }
#endif
