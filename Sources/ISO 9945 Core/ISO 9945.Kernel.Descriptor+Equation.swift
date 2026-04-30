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

import Equation_Primitives_Core

extension ISO_9945.Kernel.Descriptor: Equation.`Protocol` {
    @inlinable
    public static func == (
        lhs: borrowing ISO_9945.Kernel.Descriptor,
        rhs: borrowing ISO_9945.Kernel.Descriptor
    ) -> Bool {
        lhs._raw == rhs._raw
    }
}
