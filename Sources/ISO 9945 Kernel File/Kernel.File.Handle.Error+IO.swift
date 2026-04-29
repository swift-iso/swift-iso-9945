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

@_spi(Syscall) import Kernel_Descriptor_Primitives
@_spi(Syscall) import Kernel_File_Primitives

// L2-side conversion factory for L1 Kernel.File.Handle.Error from
// Kernel.IO.Read.Error / Kernel.IO.Write.Error (both L2 types
// post-Cycle-18h). Per the L1-domain-only/L3-composes architecture
// (locked Cycle 10), the factory cannot live at L1 because Handle.Error's
// init would need to reference L2 IO error types. Hosting the factory at
// L2 keeps both endpoints visible while preserving the architectural
// boundary: L1 Handle.Error knows nothing about L2 IO; L2 callers route
// through this conversion.

extension Kernel.File.Handle.Error {
    public init(from error: Kernel.IO.Read.Error, operation: Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }
        case .blocking:
            self = .platform(code: .posix(-1), operation: operation)
        case .platform:
            self = .platform(code: .posix(-1), operation: operation)
        }
    }

    public init(from error: Kernel.IO.Write.Error, operation: Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }
        case .blocking:
            self = .platform(code: .posix(-1), operation: operation)
        case .platform:
            self = .platform(code: .posix(-1), operation: operation)
        }
    }
}
