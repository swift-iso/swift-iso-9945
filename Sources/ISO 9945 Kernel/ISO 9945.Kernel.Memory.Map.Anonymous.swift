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

// MARK: - POSIX Anonymous Memory Mapping

extension ISO_9945.Kernel.Memory.Map.Anonymous {
    /// Creates an anonymous memory mapping.
    ///
    /// Anonymous mappings are not backed by any file. They are initialized to zero
    /// and are typically used for heap allocations or shared memory.
    ///
    /// - Parameters:
    ///   - length: Number of bytes to map (must be > 0).
    ///   - protection: Memory protection flags (default: read/write).
    ///   - shared: Whether the mapping is shared (default: private).
    /// - Returns: A region describing the mapped memory.
    /// - Throws: `Kernel.Memory.Map.Error` on failure.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Create a private anonymous mapping
    /// let region = try Kernel.Memory.Map.Anonymous.map(length: 4096)
    /// defer { try? Kernel.Memory.Map.unmap(region) }
    ///
    /// // Write to the memory
    /// region.base.mutablePointer.storeBytes(of: 42, as: Int.self)
    /// ```
    public static func map(
        length: Kernel.File.Size,
        protection: Kernel.Memory.Map.Protection = [.read, .write],
        shared: Bool = false
    ) throws(Kernel.Memory.Map.Error) -> Kernel.Memory.Map.Region {
        let sharingFlag = shared ? Kernel.Memory.Map.Flags.shared : Kernel.Memory.Map.Flags.private
        let flags = Kernel.Memory.Map.Flags(
            rawValue: Kernel.Memory.Map.Flags.anonymous.rawValue | sharingFlag.rawValue
        )

        let addr = try Kernel.Memory.Map.map(
            length: length,
            protection: protection,
            flags: flags
        )

        return Kernel.Memory.Map.Region(base: addr, length: length)
    }
}

#endif
