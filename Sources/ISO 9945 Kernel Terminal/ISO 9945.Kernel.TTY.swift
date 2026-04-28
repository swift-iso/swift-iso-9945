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

#if !os(Windows)

@_spi(Syscall) import Kernel_Terminal_Primitives
@_spi(Syscall) public import ISO_9945_Kernel_Descriptor

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CISO9945Shim)
    internal import CISO9945Shim
#endif

// MARK: - TTY Check

extension ISO_9945.Kernel.TTY {
    /// Check if a raw file descriptor refers to a terminal (syscall variant).
    ///
    /// Wraps `isatty(fd)`. Spec-literal: zero policy. The L3-policy typed-
    /// descriptor convenience lives at `POSIX.Kernel.TTY.isTTY(_:)` in
    /// swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: File descriptor to check (typically 0=stdin, 1=stdout, 2=stderr)
    /// - Returns: `true` if the descriptor refers to a terminal, `false` otherwise
    @_spi(Syscall)
    public static func isTTY(fd: Int32) -> Bool {
        isatty(fd) != 0
    }
}

// MARK: - TTY Size Query

extension ISO_9945.Kernel.TTY.Size {
    /// Query terminal size for the given raw file descriptor (syscall variant).
    ///
    /// Wraps `ioctl(fd, TIOCGWINSZ, &winsize)`. Spec-literal: zero policy
    /// (errno still surfaces via `Kernel.Error.current`). The L3-policy
    /// typed-descriptor convenience lives at `POSIX.Kernel.TTY.Size.query(_:)`
    /// in swift-posix per [PLAT-ARCH-005] / [PLAT-ARCH-008e].
    ///
    /// - Parameter fd: File descriptor (typically 0=stdin, 1=stdout, 2=stderr)
    /// - Returns: Terminal size in rows and columns
    /// - Throws: ``Kernel.Error`` if the ioctl call fails (e.g., not a terminal)
    @_spi(Syscall)
    public static func query(fd: Int32) throws(Kernel.Error) -> Self {
        var ws = winsize()
        let result = unsafe iso9945_ioctl_tiocgwinsz(fd, &ws)
        guard result == 0 else {
            throw Kernel.Error.current(operation: "ioctl(TIOCGWINSZ)")
        }
        return Self(rows: ws.ws_row, columns: ws.ws_col)
    }
}

// MARK: - Typed Convenience (Phase 1.5)

extension ISO_9945.Kernel.TTY {
    /// Check if a typed descriptor refers to a terminal.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `isTTY(fd:)` SPI form
    /// via `descriptor._rawValue`.
    public static func isTTY(_ descriptor: borrowing POSIX.Kernel.Descriptor) -> Bool {
        isTTY(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.TTY.Size {
    /// Query terminal size from a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Delegates to the raw `query(fd:)` SPI form
    /// via `descriptor._rawValue`.
    public static func query(_ descriptor: borrowing POSIX.Kernel.Descriptor) throws(Kernel.Error) -> Self {
        try query(fd: descriptor._rawValue)
    }
}

#endif
