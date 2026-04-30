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

@_spi(Syscall) import Kernel_File_Primitives

// MARK: - POSIX close on Kernel.File.Handle

extension Kernel.File.Handle {
    /// Explicitly closes the file handle with error reporting.
    ///
    /// Consumes the handle: after this call, both the handle and its
    /// descriptor are destroyed. The descriptor is disarmed before the
    /// syscall so its deinit does not double-close.
    ///
    /// If you don't call `close()` explicitly, the descriptor's deinit
    /// closes the fd automatically (best-effort, errors swallowed).
    ///
    /// - Throws: `Kernel.Close.Error` on failure.
    public consuming func close() throws(Kernel.Close.Error) {
        try Kernel.Close.close(self.descriptor)
    }
}
