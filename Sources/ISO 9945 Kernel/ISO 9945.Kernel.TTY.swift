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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

#if canImport(CPosixShim)
    internal import CPosixShim
#endif

// MARK: - TTY Check

extension ISO_9945.Kernel.TTY {
    /// Check if a file descriptor refers to a terminal.
    ///
    /// Wraps `isatty(fd)`.
    ///
    /// - Parameter fd: File descriptor to check (typically 0=stdin, 1=stdout, 2=stderr)
    /// - Returns: `true` if the descriptor refers to a terminal, `false` otherwise
    ///
    /// This is a pure observation - returns `false` on error rather than throwing.

    public static func isTTY(fd: Int32) -> Bool {
        swift_isatty(fd) != 0
    }
}

// MARK: - TTY Size Query

extension ISO_9945.Kernel.TTY.Size {
    /// Query terminal size for the given file descriptor.
    ///
    /// Wraps `ioctl(fd, TIOCGWINSZ, &winsize)`.
    ///
    /// - Parameter fd: File descriptor (typically 0=stdin, 1=stdout, 2=stderr)
    /// - Returns: Terminal size in rows and columns
    /// - Throws: ``Kernel.Error`` if the ioctl call fails (e.g., not a terminal)
    public static func query(fd: Int32) throws(Kernel.Error) -> Self {
        var ws = winsize()
        let result = unsafe swift_ioctl_tiocgwinsz(fd, &ws)
        guard result == 0 else {
            throw Kernel.Error.current(operation: "ioctl(TIOCGWINSZ)")
        }
        return Self(rows: ws.ws_row, columns: ws.ws_col)
    }
}

#endif
