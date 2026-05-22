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

import Hash_Primitives

extension ISO_9945.Kernel.Descriptor: Hash.`Protocol` {
    @inlinable
    public borrowing func hash(into hasher: inout Hasher) {
        _raw.hash(into: &hasher)
    }
}
