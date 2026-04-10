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

@_spi(Syscall) public import Kernel_Primitives_Core
@_spi(Syscall) public import Kernel_Descriptor_Primitives
@_spi(Syscall) public import Kernel_Error_Primitives
@_spi(Syscall) public import Kernel_File_Primitives
@_spi(Syscall) public import Kernel_IO_Primitives
@_spi(Syscall) public import Kernel_Socket_Primitives
@_spi(Syscall) public import Kernel_Memory_Primitives
@_spi(Syscall) public import Kernel_Process_Primitives
@_spi(Syscall) public import Kernel_Permission_Primitives
@_spi(Syscall) public import Kernel_Path_Primitives
@_spi(Syscall) public import Kernel_Thread_Primitives
@_spi(Syscall) public import Kernel_System_Primitives
@_spi(Syscall) public import Kernel_Time_Primitives
@_spi(Syscall) public import Kernel_Clock_Primitives
@_spi(Syscall) public import Kernel_Random_Primitives
@_spi(Syscall) public import Kernel_Environment_Primitives
@_spi(Syscall) public import Kernel_Syscall_Primitives
@_spi(Syscall) public import Kernel_Terminal_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif


// MARK: - Termios Attributes Get

extension ISO_9945.Kernel.Termios.Attributes {
    /// Get terminal attributes for the given file descriptor.
    ///
    /// Wraps `tcgetattr(fd, &termios)`.
    ///
    /// - Parameter fd: File descriptor (must refer to a terminal)
    /// - Returns: Current terminal attributes
    /// - Throws: ``Kernel.Error`` if the syscall fails
    public static func get(fd: Int32) throws(Kernel.Error) -> Self {
        var t = termios()
        let result = unsafe tcgetattr(fd, &t)
        guard result == 0 else {
            throw Kernel.Error.current(operation: "tcgetattr")
        }

        // Copy termios to opaque storage
        var attrs = Kernel.Termios.Attributes(_storage: .init())
        unsafe attrs.withUnsafeMutableStorageBytes { buffer in
            unsafe withUnsafeBytes(of: t) { src in
                unsafe buffer.copyMemory(from: src)
            }
        }
        return attrs
    }
}

// MARK: - Termios Attributes Set

extension ISO_9945.Kernel.Termios.Attributes {
    /// Set terminal attributes for the given file descriptor.
    ///
    /// Wraps `tcsetattr(fd, action, &termios)`.
    ///
    /// - Parameters:
    ///   - attributes: Terminal attributes to apply
    ///   - fd: File descriptor (must refer to a terminal)
    ///   - action: When to apply the changes (default: `.now`)
    /// - Throws: ``Kernel.Error`` if the syscall fails
    public static func set(
        _ attributes: Self,
        fd: Int32,
        action: Action = .now
    ) throws(Kernel.Error) {
        var t = termios()
        unsafe attributes.withUnsafeStorageBytes { buffer in
            unsafe withUnsafeMutableBytes(of: &t) { dest in
                unsafe dest.copyMemory(from: buffer)
            }
        }
        let result = unsafe tcsetattr(fd, action.rawValue, &t)
        guard result == 0 else {
            throw Kernel.Error.current(operation: "tcsetattr")
        }
    }
}

// MARK: - Action Constants

extension ISO_9945.Kernel.Termios.Attributes.Action {
    /// Apply changes immediately (TCSANOW).
    public static let now = Self(_rawValue: TCSANOW)

    /// Apply after all output has been transmitted (TCSADRAIN).
    public static let drain = Self(_rawValue: TCSADRAIN)

    /// Apply after all output transmitted, discard pending input (TCSAFLUSH).
    public static let flush = Self(_rawValue: TCSAFLUSH)
}

// MARK: - Raw Mode

extension ISO_9945.Kernel.Termios.Attributes {
    /// Returns a copy with raw mode flags applied.
    ///
    /// Raw mode disables:
    /// - Line buffering (ICANON)
    /// - Echo (ECHO, ECHOE, ECHOK, ECHONL)
    /// - Signal generation (ISIG)
    /// - Input processing (BRKINT, ICRNL, INPCK, ISTRIP, IXON)
    /// - Output processing (OPOST)
    /// - Parity checking
    ///
    /// Sets:
    /// - Character size to 8 bits (CS8)
    /// - Minimum read of 1 byte (VMIN = 1)
    /// - No timeout (VTIME = 0)
    ///
    /// This is equivalent to `cfmakeraw()` on systems that support it.
    public func withRaw() -> Self {
        var t = termios()
        unsafe self.withUnsafeStorageBytes { buffer in
            unsafe withUnsafeMutableBytes(of: &t) { dest in
                unsafe dest.copyMemory(from: buffer)
            }
        }

        // Input flags: disable all processing
        t.c_iflag &= ~tcflag_t(BRKINT | ICRNL | INPCK | ISTRIP | IXON)

        // Output flags: disable post-processing
        t.c_oflag &= ~tcflag_t(OPOST)

        // Control flags: 8-bit characters
        t.c_cflag &= ~tcflag_t(CSIZE | PARENB)
        t.c_cflag |= tcflag_t(CS8)

        // Local flags: disable canonical mode, echo, signals
        t.c_lflag &= ~tcflag_t(ECHO | ECHONL | ICANON | ISIG | IEXTEN)

        // Control characters: read returns immediately with 1+ bytes
        // c_cc is a tuple on Darwin, need to use withUnsafeMutablePointer
        unsafe withUnsafeMutablePointer(to: &t.c_cc) { ptr in
            unsafe ptr.withMemoryRebound(to: cc_t.self, capacity: Int(NCCS)) { cc in
                unsafe (cc[Int(VMIN)] = 1)
                unsafe (cc[Int(VTIME)] = 0)
            }
        }

        var result = Kernel.Termios.Attributes(_storage: .init())
        unsafe result.withUnsafeMutableStorageBytes { buffer in
            unsafe withUnsafeBytes(of: t) { src in
                unsafe buffer.copyMemory(from: src)
            }
        }
        return result
    }
}

#endif
