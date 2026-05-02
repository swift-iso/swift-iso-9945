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

public import Carrier_Primitives

// Trivial self-carrier conformance. Defaults for `var underlying: Self` and
// `init(_:)` come from `Carrier where Underlying == Self` at swift-carrier-primitives.
// Enables `some Carrier<ISO_9945.Kernel.File.Stats>` to accept the bare L2
// struct AND `Tagged<POSIX, ISO_9945.Kernel.File.Stats>` (the L3 variant)
// uniformly via Tagged's cascading Carrier conformance.

extension ISO_9945.Kernel.File.Stats: Carrier {
    public typealias Underlying = ISO_9945.Kernel.File.Stats
}
