// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension ISO_9945.Glob.Fnmatch {
    /// Errors from `fnmatch(3)`.
    ///
    /// POSIX defines the error outcome only as "another non-zero value";
    /// the raw code is carried unrelabelled.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// `fnmatch` returned a value that is neither 0 nor `FNM_NOMATCH`.
        case failed(code: Int32)
    }
}
