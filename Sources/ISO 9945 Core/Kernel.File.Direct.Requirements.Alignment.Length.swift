// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//



extension ISO_9945.Kernel.File.Direct.Requirements.Alignment {
    /// Accessor for length validation.
    public struct Length: Sendable {
        let alignment: ISO_9945.Kernel.File.Direct.Requirements.Alignment

        /// Validates that an I/O length is a valid multiple.
        ///
        /// - Parameter length: The transfer length to validate.
        /// - Returns: `true` if the length is a multiple of `lengthMultiple`.
        public func isValid(_ length: ISO_9945.Kernel.File.Size) -> Bool {
            let mask: Int64 = alignment.lengthMultiple.mask()
            return length.underlying & mask == 0
        }
    }

    /// Accessor for length validation.
    public var length: Length { Length(alignment: self) }
}

