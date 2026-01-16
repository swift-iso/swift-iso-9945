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
    internal import CDarwinShim
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - POSIX Shared Memory

extension ISO_9945.Kernel.Memory.Shared {
    /// Opens or creates a POSIX shared memory object.
    ///
    /// ## Threading
    /// This call may block briefly during kernel object creation/lookup.
    /// The returned descriptor can be used from any thread but requires
    /// explicit synchronization for the mapped memory region.
    ///
    /// ## Descriptor Lifecycle
    /// 1. Call `open()` to get a descriptor
    /// 2. Set size with `ftruncate()` if creating
    /// 3. Map with ``Kernel/Memory/Map/map(_:length:protection:flags:offset:)``
    /// 4. Use the mapped region (with synchronization)
    /// 5. Unmap with ``Kernel/Memory/Map/unmap(_:length:)``
    /// 6. Close with ``Kernel/Close/close(_:)``
    /// 7. Optionally unlink with ``unlink(name:)``
    ///
    /// ## Errors
    /// - ``Error/open(_:)``: shm_open failed (permission denied, name invalid, etc.)
    ///
    /// - Parameters:
    ///   - name: The name of the shared memory object (must start with '/').
    ///   - access: Read/write access mode.
    ///   - options: Creation options (create, exclusive, truncate).
    ///   - permissions: Permission mode for creation.
    /// - Returns: A file descriptor for the shared memory object.
    /// - Throws: ``Kernel/Memory/Shared/Error`` on failure.

    @unsafe
    public static func open(
        name: UnsafePointer<CChar>,
        access: Kernel.Memory.Shared.Access,
        options: Kernel.Memory.Shared.Options = [],
        permissions: Kernel.File.Permissions = .ownerReadWrite
    ) throws(Kernel.Memory.Shared.Error) -> Kernel.Descriptor {
        let flags = access.posixFlags | options.posixFlags

        #if canImport(Darwin)
            // Use shim because Darwin declares shm_open as variadic
            let fd = unsafe swift_shm_open(name, flags, mode_t(permissions.rawValue))
        #else
            let fd = unsafe shm_open(name, flags, mode_t(permissions.rawValue))
        #endif

        guard fd >= 0 else {
            throw .open(Kernel.Error.Code.captureErrno())
        }
        return Kernel.Descriptor(_rawValue: fd)
    }

    /// Removes a POSIX shared memory object.
    ///
    /// - Parameter name: The name of the shared memory object to remove.
    /// - Throws: `Error.unlink` on failure.

    @unsafe
    public static func unlink(name: UnsafePointer<CChar>) throws(Kernel.Memory.Shared.Error) {
        guard unsafe shm_unlink(name) == 0 else {
            throw .unlink(Kernel.Error.Code.captureErrno())
        }
    }
}
