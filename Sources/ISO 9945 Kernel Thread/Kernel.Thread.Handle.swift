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

// MARK: - Thread Handle
//
// Thread handle implementation is in platform-specific packages:
// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.Thread.Handle`)
//
// Thread handles require platform-specific storage (pthread_t / HANDLE)
// and operations (pthread_join / WaitForSingleObject), so they cannot live
// in the types-only primitives layer.
