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

extension ISO_9945.Kernel.Device {
    /// Type-safe wrapper for a minor device number.
    ///
    /// This is a semantic wrapper only, not a validated range.
    /// Construction does not enforce kernel limits.
    public struct Minor: RawRepresentable, Sendable, Equatable, Hashable {
        public let rawValue: UInt32

        public init(rawValue: UInt32) {
            self.rawValue = rawValue
        }
    }
}

extension ISO_9945.Kernel.Device.Minor: ExpressibleByIntegerLiteral {
    public init(integerLiteral value: UInt32) {
        self.init(rawValue: value)
    }
}

extension ISO_9945.Kernel.Device.Minor: CustomStringConvertible {
    public var description: Swift.String {
        "\(rawValue)"
    }
}
