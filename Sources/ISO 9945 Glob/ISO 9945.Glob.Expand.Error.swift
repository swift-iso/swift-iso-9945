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

extension ISO_9945.Glob.Expand {
    /// Errors from `glob(3)`.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Memory allocation failure (`GLOB_NOSPACE`).
        case noSpace

        /// Read error or error function returned non-zero (`GLOB_ABORTED`).
        case aborted

        /// No matches found (`GLOB_NOMATCH`).
        case noMatch

        /// `glob` returned a value outside its documented set.
        ///
        /// Not relabelled as one of the documented errors: the raw code
        /// is carried so the condition stays identifiable.
        case unrecognized(code: Int32)
    }
}
