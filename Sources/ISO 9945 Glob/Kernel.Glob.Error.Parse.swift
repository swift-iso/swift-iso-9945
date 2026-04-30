// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.Glob.Error {
    /// Pattern parse error reasons.
    public enum Parse: Sendable, Hashable {
        /// Character class `[...]` was not closed with `]`.
        case unterminatedClass

        /// Character class `[]` is empty.
        case emptyClass

        /// Invalid range in character class (e.g., `[z-a]`).
        case invalidRange

        /// Pattern ended unexpectedly (e.g., trailing `\`).
        case unexpectedEnd

        /// Invalid escape sequence.
        case invalidEscape
    }
}

