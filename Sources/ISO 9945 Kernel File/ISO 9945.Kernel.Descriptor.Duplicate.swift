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

    /// Duplicates a file descriptor into an existing descriptor slot, atomically
    /// replacing the kernel resource at that slot.
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
