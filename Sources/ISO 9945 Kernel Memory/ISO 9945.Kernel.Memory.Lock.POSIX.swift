// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-posix open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-posix project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// MARK: - POSIX-Specific Typed API

extension ISO_9945.Kernel.Memory.Lock {
    /// Locks all current and/or future pages using typed flags.
    ///
    /// - Parameter flags: Typed flags for mlockall.
    /// - Throws: `Error.lockAll` on failure.

    public static func lockAll(_ flags: All.Options) throws(Error) {
        try lockAll(flags: flags.rawValue)
    }
}
