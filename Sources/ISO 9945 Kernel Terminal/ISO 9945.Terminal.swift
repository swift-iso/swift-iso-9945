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

/// POSIX implementation of Terminal operations.

#if !os(Windows)

// MARK: - Interactivity

extension Terminal.Stream.Interactive {
    /// Check if this stream is attached to an interactive terminal.
    ///
    /// Uses `Kernel.TTY.isTTY()` which wraps `isatty()`.
    public func callAsFunction() -> Bool {
        Kernel.TTY.isTTY(fd: stream.rawValue)
    }
}

// MARK: - Size

extension Terminal.Size {
    /// Query terminal dimensions.
    ///
    /// Uses `Kernel.TTY.Size.query()` which wraps `ioctl(TIOCGWINSZ)`.
    ///
    /// - Parameter stream: Stream to query (default: stdout)
    /// - Returns: Terminal size in rows and columns
    /// - Throws: ``Terminal.Error`` if query fails
    public static func query(stream: Terminal.Stream = .stdout) throws(Terminal.Error) -> Self {
        do {
            let kernelSize = try Kernel.TTY.Size.query(fd: stream.rawValue)
            return Terminal.Size(rows: kernelSize.rows, columns: kernelSize.columns)
        } catch let error {
            throw Terminal.Error(operation: .querySize, underlying: .kernel(error))
        }
    }
}

// Raw mode enter() and restore() relocated to L3 swift-kernel
// (Sources/Kernel Terminal/Terminal.Mode.Raw.Token.swift) in Cycle 22:
// they reference Token + Previous which moved to L3 because Previous's
// .posix case carries Kernel.Termios.Attributes — an L2 type post-Cycle-22 —
// so the Token nested type cannot live at L1 swift-terminal-primitives.

#endif
