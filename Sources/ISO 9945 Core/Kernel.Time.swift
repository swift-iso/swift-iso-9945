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

// Cycle G6.A: After L1 Kernel Time Primitives deletion, the typealias
// Kernel.Time = Instant lives at L3 swift-kernel (Kernel Core target),
// which iso-9945 (L2) cannot import. This file declares the same
// typealias at iso-9945 L2 so iso-9945's own POSIX time wrappers
// (ISO_9945.Kernel.Time.realtime() etc.) and consumers (File.Stats)
// can resolve `Kernel.Time` within the iso-9945 scope.
//
// Both typealiases (L2 here, L3 swift-kernel) resolve to the same
// underlying type (Instant from Time_Primitives), so cross-package
// consumers see the same Kernel.Time identity.

public import Time_Primitives_Core

extension ISO_9945.Kernel {
    public typealias Time = Instant
}
