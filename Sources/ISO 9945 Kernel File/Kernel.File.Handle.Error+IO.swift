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

// L2-side conversion factory for L1 ISO_9945.Kernel.File.Handle.Error from
// ISO_9945.Kernel.IO.Read.Error / ISO_9945.Kernel.IO.Write.Error (both L2 types
// post-Cycle-18h). Per the L1-domain-only/L3-composes architecture
// (locked Cycle 10), the factory cannot live at L1 because Handle.Error's
// init would need to reference L2 IO error types. Hosting the factory at
// L2 keeps both endpoints visible while preserving the architectural
// boundary: L1 Handle.Error knows nothing about L2 IO; L2 callers route
// through this conversion.

extension ISO_9945.Kernel.File.Handle.Error {
    public init(from error: ISO_9945.Kernel.IO.Read.Error, operation: ISO_9945.Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:
            // A would-block condition is EAGAIN by definition; preserve the
            // platform-correct code rather than fabricating one.
            self = .platform(code: Error_Primitives.Error.Code.POSIX.EAGAIN, operation: operation)

        case .platform(let platformError):
            // Preserve the real errno so ENOSPC, EIO, EFBIG, … stay
            // distinguishable at the Handle surface.
            self = .platform(code: platformError.code, operation: operation)
        }
    }

    public init(from error: ISO_9945.Kernel.IO.Write.Error, operation: ISO_9945.Kernel.File.Handle.Operation) {
        switch error {
        case .handle(let handleError):
            switch handleError {
            case .invalid, .limit:
                self = .invalidHandle
            }

        case .blocking:
            // A would-block condition is EAGAIN by definition; preserve the
            // platform-correct code rather than fabricating one.
            self = .platform(code: Error_Primitives.Error.Code.POSIX.EAGAIN, operation: operation)

        case .platform(let platformError):
            // Preserve the real errno so ENOSPC, EIO, EFBIG, … stay
            // distinguishable at the Handle surface.
            self = .platform(code: platformError.code, operation: operation)
        }
    }
}
