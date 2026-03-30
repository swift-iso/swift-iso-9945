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

@_spi(Syscall) public import Kernel_Primitives
public import ISO_9945

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX dup() syscalls

extension ISO_9945.Kernel.Descriptor.Duplicate {
    /// Duplicates a file descriptor.
    ///
    /// Creates a copy of the file descriptor using the lowest-numbered
    /// available file descriptor.
    ///
    /// - Parameter descriptor: The file descriptor to duplicate.
    /// - Returns: The new file descriptor.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(_ descriptor: borrowing Kernel.Descriptor) throws(Error) -> Kernel.Descriptor {
        #if canImport(Darwin)
            let result = Darwin.dup(descriptor._rawValue)
        #elseif canImport(Musl)
            let result = Musl.dup(descriptor._rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.dup(descriptor._rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return Kernel.Descriptor(_rawValue: result)
    }

    /// Duplicates a file descriptor to a specific descriptor number.
    ///
    /// If `newDescriptor` is already open, it is first closed. The new
    /// descriptor is guaranteed to be `newDescriptor`.
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to duplicate.
    ///   - newDescriptor: The target descriptor number.
    /// - Returns: The new file descriptor (same as `newDescriptor`).
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    @discardableResult
    public static func duplicate(
        _ descriptor: borrowing Kernel.Descriptor,
        to newDescriptor: borrowing Kernel.Descriptor
    ) throws(Error) -> Kernel.Descriptor {
        #if canImport(Darwin)
            let result = Darwin.dup2(descriptor._rawValue, newDescriptor._rawValue)
        #elseif canImport(Musl)
            let result = Musl.dup2(descriptor._rawValue, newDescriptor._rawValue)
        #elseif canImport(Glibc)
            let result = Glibc.dup2(descriptor._rawValue, newDescriptor._rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return Kernel.Descriptor(_rawValue: result)
    }

    #if os(Linux)
    /// Duplicates a file descriptor with flags (Linux).
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to duplicate.
    ///   - newDescriptor: The target descriptor number.
    ///   - flags: Flags to apply (currently only O_CLOEXEC).
    /// - Returns: The new file descriptor.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    @discardableResult
    public static func duplicate(
        _ descriptor: borrowing Kernel.Descriptor,
        to newDescriptor: borrowing Kernel.Descriptor,
        flags: Flags
    ) throws(Error) -> Kernel.Descriptor {
        let result = Glibc.dup3(descriptor._rawValue, newDescriptor._rawValue, flags.rawValue)

        guard result >= 0 else {
            throw Error.current()
        }
        return Kernel.Descriptor(_rawValue: result)
    }

    /// Flags for duplicate with flags (Linux).
    public struct Flags: OptionSet, Sendable {
        public let rawValue: Int32

        public init(rawValue: Int32) {
            self.rawValue = rawValue
        }

        /// Set the close-on-exec flag on the new file descriptor.
        public static let closeOnExec = Flags(rawValue: O_CLOEXEC)
    }
    #endif
}

// MARK: - Error

extension ISO_9945.Kernel.Descriptor.Duplicate {
    public typealias Error = Kernel.Descriptor.Duplicate.Error
}

extension ISO_9945.Kernel.Descriptor.Duplicate.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let e = errno
        switch e {
        case EBADF:
            return .handle(.invalid)
        case EMFILE:
            return .tooManyOpen
        default:
            return .platform(Kernel.Error(code: .posix(e)))
        }
    }
}

extension ISO_9945.Kernel.Descriptor.Duplicate.Error: @retroactive CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .handle(let e):
            return "handle: \(e)"
        case .tooManyOpen:
            return "Too many file descriptors open"
        case .platform(let e):
            return "\(e)"
        }
    }
}
