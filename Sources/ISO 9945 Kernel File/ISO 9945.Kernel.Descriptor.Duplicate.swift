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

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX dup() syscalls (raw @_spi(Syscall))

extension ISO_9945.Kernel.Descriptor.Duplicate {
    /// Duplicates a raw file descriptor.
    ///
    /// Spec-literal raw `dup(2)`. Creates a copy of the file descriptor using
    /// the lowest-numbered available file descriptor. The typed L2 convenience
    /// (`ISO_9945.Kernel.Descriptor.Duplicate.duplicate(_:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameter fd: The raw file descriptor to duplicate.
    /// - Returns: The new raw file descriptor.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    @_spi(Syscall)
    public static func duplicate(fd: Int32) throws(Error) -> Int32 {
        #if canImport(Darwin)
            let result = unsafe Darwin.dup(fd)
        #elseif canImport(Musl)
            let result = unsafe Musl.dup(fd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.dup(fd)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return result
    }

    /// Duplicates a raw file descriptor into an existing slot, atomically
    /// replacing the kernel resource at that slot.
    ///
    /// Spec-literal raw `dup2(2)`. The kernel resource previously held at
    /// `newFd`'s slot is closed atomically, and the slot is repointed to a
    /// duplicate of `fd`'s resource. The typed L2 convenience
    /// (`ISO_9945.Kernel.Descriptor.Duplicate.duplicate(_:to:)` taking
    /// `borrowing Kernel.Descriptor`) delegates to this raw SPI internally.
    ///
    /// - Parameters:
    ///   - fd: The raw file descriptor to duplicate.
    ///   - newFd: The target slot. After return, this slot refers to the
    ///     duplicated kernel resource.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure. On throw,
    ///   `newFd`'s slot is unchanged and still refers to its original
    ///   resource.
    @_spi(Syscall)
    public static func duplicate(
        fd: Int32,
        toFd newFd: Int32
    ) throws(Error) {
        #if canImport(Darwin)
            let result = unsafe Darwin.dup2(fd, newFd)
        #elseif canImport(Musl)
            let result = unsafe Musl.dup2(fd, newFd)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.dup2(fd, newFd)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
    }
}

// MARK: - Typed Convenience

extension ISO_9945.Kernel.Descriptor.Duplicate {
    /// Duplicates a file descriptor.
    ///
    /// Typed L2 form. Delegates to the raw `duplicate(fd:)` SPI via
    /// `descriptor._rawValue` and wraps the returned raw fd in a typed
    /// `Kernel.Descriptor`.
    ///
    /// Creates a copy of the file descriptor using the lowest-numbered
    /// available file descriptor.
    ///
    /// - Parameter descriptor: The file descriptor to duplicate.
    /// - Returns: The new file descriptor.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure.
    public static func duplicate(_ descriptor: borrowing Kernel.Descriptor) throws(Error) -> Kernel.Descriptor {
        let rawNew = try unsafe duplicate(fd: descriptor._rawValue)
        return Kernel.Descriptor(_rawValue: rawNew)
    }

    /// Duplicates a file descriptor into an existing descriptor slot, atomically
    /// replacing the kernel resource at that slot.
    ///
    /// Typed L2 form. Delegates to the raw `duplicate(fd:toFd:)` SPI via
    /// `descriptor._rawValue`.
    ///
    /// `dup2(2)` semantics: the kernel resource previously held at `newDescriptor`'s
    /// slot is closed atomically, and the slot is repointed to a duplicate of
    /// `descriptor`'s resource. The slot number itself does not change — only
    /// the resource it refers to.
    ///
    /// Because the slot number is unchanged, the `newDescriptor` wrapper needs
    /// no state mutation: its `_raw` still holds the same fd number, which now
    /// refers to the duplicate. The `inout` parameter expresses the exclusive
    /// borrow required for the syscall and prevents aliasing constructions
    /// (e.g., returning a second `Kernel.Descriptor` wrapping the same slot).
    ///
    /// - Parameters:
    ///   - descriptor: The file descriptor to duplicate.
    ///   - newDescriptor: The target slot. Mutated in place: on success, this
    ///     wrapper now refers to the new (duplicated) kernel resource.
    /// - Throws: `Kernel.Descriptor.Duplicate.Error` on failure. On throw,
    ///   `newDescriptor` is unchanged and still refers to its original resource.
    public static func duplicate(
        _ descriptor: borrowing Kernel.Descriptor,
        to newDescriptor: inout Kernel.Descriptor
    ) throws(Error) {
        try unsafe duplicate(fd: descriptor._rawValue, toFd: newDescriptor._rawValue)
        // dup2 returns newDescriptor's slot — the wrapper's _raw is already
        // correct. No state change. The kernel resource at that slot has been
        // replaced atomically by the kernel; from Swift's view, newDescriptor
        // simply refers to a different (duplicated) resource now.
    }
}

// MARK: - Error

extension ISO_9945.Kernel.Descriptor.Duplicate {
    public typealias Error = Kernel.Descriptor.Duplicate.Error
}

extension ISO_9945.Kernel.Descriptor.Duplicate.Error {
    /// Creates an error from the current errno value.
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .EBADF:
            return .handle(.invalid)
        case .EMFILE:
            return .tooManyOpen
        default:
            return .platform(Error_Primitives.Error(code: code))
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
