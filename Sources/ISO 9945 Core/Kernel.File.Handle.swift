// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-kernel open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-kernel project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//


extension ISO_9945.Kernel.File {
    /// A move-only file handle with Direct I/O support.
    ///
    /// `ISO_9945.Kernel.File.Handle` owns a file descriptor and stores the resolved
    /// Direct I/O mode and alignment requirements. These are fixed at
    /// open time and cannot be changed.
    ///
    /// ## Direct I/O Invariants
    ///
    /// When `direct == .direct`:
    /// - All read/write operations validate alignment
    /// - Buffer addresses must be aligned to `requirements.bufferAlignment`
    /// - File offsets must be aligned to `requirements.offsetAlignment`
    /// - Transfer lengths must be multiples of `requirements.lengthMultiple`
    ///
    /// When `direct == .uncached` (macOS) or `direct == .buffered`:
    /// - No alignment validation is performed
    /// - Operations use normal page cache semantics
    ///
    /// ## Lifecycle
    ///
    /// The handle closes the descriptor on deinit. For explicit control,
    /// use the `close()` consuming function.
    ///
    /// ## Platform Implementation
    ///
    /// Handle operations are in platform-specific packages:
    /// - POSIX: `swift-iso-9945` (`ISO_9945.Kernel.File.Handle`)
    /// - Windows: `swift-windows-primitives` (`Windows.Kernel.File.Handle`)
    @frozen
    public struct Handle: ~Copyable, Sendable {
        /// The underlying file descriptor.
        public let descriptor: ISO_9945.Kernel.File.Descriptor

        /// The resolved Direct I/O mode (fixed at open time).
        public let direct: ISO_9945.Kernel.File.Direct.Mode.Resolved

        /// The alignment requirements (fixed at open time).
        ///
        /// For `.direct` mode, this is always `.known(...)`.
        /// For `.uncached` or `.buffered`, this may be `.unknown(...)`.
        public let requirements: ISO_9945.Kernel.File.Direct.Requirements

        /// Creates a handle from a descriptor with Direct I/O state.
        ///
        /// - Parameters:
        ///   - descriptor: The file descriptor (ownership transferred).
        ///   - direct: The resolved Direct I/O mode.
        ///   - requirements: The alignment requirements.
        public init(
            descriptor: consuming ISO_9945.Kernel.File.Descriptor,
            direct: ISO_9945.Kernel.File.Direct.Mode.Resolved,
            requirements: ISO_9945.Kernel.File.Direct.Requirements
        ) {
            self.descriptor = descriptor
            self.direct = direct
            self.requirements = requirements
        }

        // Note: deinit, read(), write(), and close() implementations are in platform packages:
        // - POSIX: swift-iso-9945 (ISO_9945.Kernel.File.Handle)
        // - Windows: swift-windows-primitives (Windows.Kernel.File.Handle)
    }
}

// MARK: - Alignment Validation

extension ISO_9945.Kernel.File.Handle {
    /// Validates alignment requirements for Direct I/O.
    ///
    /// - Parameters:
    ///   - buffer: The buffer address.
    ///   - offset: The file offset.
    ///   - length: The transfer length.
    /// - Throws: `ISO_9945.Kernel.File.Handle.Error` on alignment violation.
    private func validateAlignment(
        buffer: Memory.Address,
        offset: ISO_9945.Kernel.File.Offset,
        length: ISO_9945.Kernel.File.Size
    ) throws(ISO_9945.Kernel.File.Handle.Error) {
        guard case .known(let alignment) = requirements else {
            throw .requirementsUnknown
        }

        if let directError = alignment.validate(buffer: buffer, offset: offset, length: length) {
            throw Error(from: directError)
        }
    }
}

