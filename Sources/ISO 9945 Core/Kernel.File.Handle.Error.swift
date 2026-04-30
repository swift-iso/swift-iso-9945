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




extension ISO_9945.Kernel.File.Handle {
    /// Errors that can occur during file handle operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// The file handle is invalid or closed.
        case invalidHandle

        /// End of file reached.
        case endOfFile

        /// No space left on device.
        case noSpace

        /// Buffer alignment violation for Direct I/O (detected by pre-validation).
        case misalignedBuffer(address: Memory.Address, required: Memory.Alignment)

        /// Offset alignment violation for Direct I/O (detected by pre-validation).
        case misalignedOffset(offset: Int64, required: Memory.Alignment)

        /// Length not a multiple of required granularity (detected by pre-validation).
        case invalidLength(length: Int, requiredMultiple: Memory.Alignment)

        /// Direct I/O requirements are unknown.
        case requirementsUnknown

        /// Alignment violation or Direct I/O not supported (detected by kernel).
        ///
        /// This error occurs when the kernel rejects an I/O operation with `EINVAL`
        /// (POSIX) or `ERROR_INVALID_PARAMETER` (Windows). In Direct I/O mode,
        /// this typically indicates:
        ///
        /// - Buffer address not aligned to required boundary
        /// - File offset not aligned
        /// - Transfer length not a multiple of sector/block size
        /// - Direct I/O not supported by the filesystem/device
        ///
        /// **Note:** This error may occur even if pre-validation passed, because
        /// alignment requirements are not always reliably discoverable, especially
        /// on Linux. See `ISO_9945.Kernel.File.Direct.requirements(for:)` documentation.
        case alignmentViolation(operation: Operation)

        /// Platform-specific error.
        case platform(code: Error_Primitives.Error.Code, operation: Operation)
    }
}

// MARK: - From Direct Error

extension ISO_9945.Kernel.File.Handle.Error {
    /// Creates a handle error from a Direct I/O error.
    public init(from directError: ISO_9945.Kernel.File.Direct.Error) {
        switch directError {
        case .notSupported:
            self = .requirementsUnknown
        case .misalignedBuffer(let address, let required):
            self = .misalignedBuffer(address: address, required: required)
        case .misalignedOffset(let offset, let required):
            self = .misalignedOffset(offset: offset, required: required)
        case .invalidLength(let length, let requiredMultiple):
            self = .invalidLength(length: length, requiredMultiple: requiredMultiple)
        case .modeChange:
            self = .platform(code: .posix(-1), operation: .sync)
        case .invalidHandle:
            self = .invalidHandle
        case .platform(let code, let operation):
            // Map Direct.Error operation to Handle.Error operation
            switch operation {
            case .open:
                self = .platform(code: code, operation: .read)
            case .cache, .sector:
                self = .platform(code: code, operation: .sync)
            case .read:
                self = .platform(code: code, operation: .read)
            case .write:
                self = .platform(code: code, operation: .write)
            }
        }
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.File.Handle.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .invalidHandle:
            return "Invalid file handle"
        case .endOfFile:
            return "End of file"
        case .noSpace:
            return "No space left on device"
        case .misalignedBuffer(let address, let required):
            return "Buffer address \(address) not aligned to \(required)"
        case .misalignedOffset(let offset, let required):
            return "File offset \(offset) not aligned to \(required) bytes"
        case .invalidLength(let length, let requiredMultiple):
            return "Length \(length) is not a multiple of \(requiredMultiple)"
        case .requirementsUnknown:
            return "Direct I/O requirements unknown"
        case .alignmentViolation(let operation):
            return "Alignment violation or Direct I/O not supported during \(operation.rawValue)"
        case .platform(let code, let operation):
            return "Platform error \(code) during \(operation.rawValue)"
        }
    }
}

