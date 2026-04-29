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

@_spi(Syscall) import Kernel_Memory_Primitives
@_spi(Syscall) import Kernel_Descriptor_Primitives

#if canImport(Darwin)
    internal import Darwin
    internal import CISO9945Shim
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

    /// Raw POSIX `shm_open(3)` syscall.
    ///
    /// Spec-literal name (`shm_open`) matching the C function. Returns the
    /// raw `Int32` fd. Zero descriptor construction: the L3-policy wrapper
    /// at swift-posix (`Kernel.Memory.Shared.open(...) -> Kernel.Descriptor`)
    /// wraps the result in `Kernel.Descriptor(_rawValue:)` per
    /// [PLAT-ARCH-005] / [PLAT-ARCH-008e]. § 5.6 handle-returning
    /// bifurcation case.
    ///
    /// The spec-literal rename (`open` → `shm_open`) frees the intent name
    /// `open` for the L3-policy entry per [PLAT-ARCH-008e]'s namespace-
    /// identity disambiguation rule (Phase-A-rename pattern).
    @_spi(Syscall) @unsafe
    public static func shm_open(
        name: UnsafePointer<CChar>,
        access: Kernel.Memory.Shared.Access,
        options: Kernel.Memory.Shared.Options = [],
        permissions: Kernel.File.Permissions = .ownerReadWrite
    ) throws(Kernel.Memory.Shared.Error) -> Int32 {
        // Convert Access to POSIX flags at syscall boundary
        let accessMode: Int32 = switch (access.read, access.write) {
        case (true, false):  O_RDONLY
        case (false, true):  O_WRONLY
        case (true, true):   O_RDWR
        case (false, false): O_RDONLY
        }

        let flags = accessMode | options.rawValue

        #if canImport(Darwin)
            // Use shim because Darwin declares shm_open as variadic
            let fd = unsafe iso9945_shm_open(name, flags, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            // Module-qualify to disambiguate from the enclosing static method.
            let fd = unsafe Glibc.shm_open(name, flags, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let fd = unsafe Musl.shm_open(name, flags, mode_t(permissions.rawValue))
        #endif

        guard fd >= 0 else {
            throw .open(Error_Primitives.Error.Code.captureErrno())
        }
        return fd
    }

    /// Opens or creates a POSIX shared memory object, returning a typed descriptor.
    ///
    /// Phase 1.5 typed L2 form. Composes the raw `shm_open` SPI form with
    /// `Kernel.Descriptor(_rawValue:)` construction. § 5.6 handle-returning
    /// bifurcation case: the kernel produces the fd; this typed form wraps it
    /// in the L1 descriptor type.
    @unsafe
    public static func open(
        name: UnsafePointer<CChar>,
        access: Kernel.Memory.Shared.Access,
        options: Kernel.Memory.Shared.Options = [],
        permissions: Kernel.File.Permissions = .ownerReadWrite
    ) throws(Kernel.Memory.Shared.Error) -> Kernel.Descriptor {
        let fd = try unsafe shm_open(
            name: name,
            access: access,
            options: options,
            permissions: permissions
        )
        return unsafe Kernel.Descriptor(_rawValue: fd)
    }

    /// Removes a POSIX shared memory object.
    ///
    /// - Parameter name: The name of the shared memory object to remove.
    /// - Throws: `Error.unlink` on failure.

    @unsafe
    public static func unlink(name: UnsafePointer<CChar>) throws(Kernel.Memory.Shared.Error) {
        guard unsafe shm_unlink(name) == 0 else {
            throw .unlink(Error_Primitives.Error.Code.captureErrno())
        }
    }
}
