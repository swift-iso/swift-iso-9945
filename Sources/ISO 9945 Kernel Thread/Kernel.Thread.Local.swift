// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


// MARK: - Thread Local
//
// Thread-local storage implementation is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread.Key`) — pthread_key_*
// - Windows: `swift-windows-standard` (`Windows.Kernel.Thread.Index`) —
//   TlsAlloc/TlsGetValue/TlsSetValue/TlsFree
//
// The L2 raw classes are spec-literal (POSIX `pthread_key_t` →
// `Key`; Windows TLS index → `Index`) per [API-NAME-003]. The L3
// unifier `Kernel.Thread.Local<Payload>` (in `swift-kernel`) wraps
// either platform raw class with typed payload accessors — per
// [PLAT-ARCH-008f] solution (a).
//
// Thread-local storage requires platform-specific key allocation and
// per-thread slot machinery, so it cannot live in the types-only
// primitives layer per [PLAT-ARCH-008c]. The L2 implementations expose
// a Swift-native `UnsafeMutableRawPointer?` slot per [PLAT-ARCH-005a]
// — no platform C types in the public API.
//
// Use case: thread-local context propagation for synchronous primitives
// that need to thread state across calls without explicit parameter
// passing — e.g., observation tracking contexts (where SwiftUI body
// evaluation is synchronous and TaskLocal would not propagate).

