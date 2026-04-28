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

/// POSIX namespace for spec-defined types and operations.
///
/// POSIX (IEEE 1003.1) is the spec encoded by ISO 9945. This namespace hosts
/// POSIX-spec-mirroring types whose definition belongs at L2 — most notably
/// `POSIX.Kernel.Descriptor` per Phase 1.5 of Path X.
///
/// L3-policy extensions (EINTR retry, partial-IO loops, error normalization)
/// live at swift-posix and extend `POSIX.Kernel.X` from this base namespace.
public enum POSIX: Sendable {
    /// POSIX kernel namespace.
    public enum Kernel: Sendable {}
}
