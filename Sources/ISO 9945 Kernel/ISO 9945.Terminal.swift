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

public import Terminal_Primitives
internal import Kernel_Primitives

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

// MARK: - Raw Mode

extension Terminal.Mode.Raw {
    /// Enter raw mode on this stream.
    ///
    /// Uses `Kernel.Termios.Attributes.get/set()` which wraps `tcgetattr/tcsetattr`.
    ///
    /// Returns a token that must be used to restore the previous mode.
    /// Call `restore()` on the token to exit raw mode.
    ///
    /// - Returns: A token to restore the previous terminal mode
    /// - Throws: ``Terminal.Error`` if entering raw mode fails
    public func enter() throws(Terminal.Error) -> Token {
        do {
            let original = try Kernel.Termios.Attributes.get(fd: stream.rawValue)
            let raw = original.withRaw()
            try Kernel.Termios.Attributes.set(raw, fd: stream.rawValue)
            return Token(stream: stream, previous: .posix(original))
        } catch let error {
            throw Terminal.Error(operation: .enterRaw, underlying: .kernel(error))
        }
    }
}

extension Terminal.Mode.Raw.Token {
    /// Restore the previous terminal mode.
    ///
    /// - Throws: ``Terminal.Error`` if restoration fails
    public mutating func restore() throws(Terminal.Error) {
        guard !restored else { return }
        guard case .posix(let attrs) = previous else {
            throw Terminal.Error(operation: .exitRaw, underlying: .unsupported)
        }
        do {
            try Kernel.Termios.Attributes.set(attrs, fd: stream.rawValue)
            restored = true
        } catch let error {
            throw Terminal.Error(operation: .exitRaw, underlying: .kernel(error))
        }
    }
}

#endif
