// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

// ISO 9945.Kernel.Lock.Scope.Error.swift
// swift-iso-9945

extension ISO_9945.Kernel.Lock.Scope {
    /// Error thrown by scoped locking helpers.
    public enum Error<E: Swift.Error>: Swift.Error, Sendable {
        /// Lock acquisition or release failed.
        case lock(ISO_9945.Kernel.Lock.Error)
        /// The body closure threw an error.
        case body(E)
    }
}
