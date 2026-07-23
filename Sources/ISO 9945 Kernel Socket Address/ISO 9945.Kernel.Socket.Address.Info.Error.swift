// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2026 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Info {
    /// Host-resolution failures (`EAI_*`).
    ///
    /// Mirrors the POSIX `getaddrinfo` error codes. `EAI_SYSTEM` carries the
    /// `errno` captured immediately after the failing call.
    public enum Error: Swift.Error, Sendable, Equatable, Hashable {
        /// The name could not be resolved at this time (EAI_AGAIN).
        case again

        /// The options had an invalid value (EAI_BADFLAGS).
        case badFlags

        /// A non-recoverable error occurred (EAI_FAIL).
        case fail

        /// The address family was not recognized or is unsupported (EAI_FAMILY).
        case family

        /// There was a memory allocation failure (EAI_MEMORY).
        case memory

        /// The name does not resolve for the supplied parameters (EAI_NONAME).
        case noName

        /// An argument buffer overflowed (EAI_OVERFLOW).
        case overflow

        /// The service was not recognized for the socket type (EAI_SERVICE).
        case service

        /// The intended socket type was not recognized (EAI_SOCKTYPE).
        case socketType

        /// A system error occurred (EAI_SYSTEM); the payload is the captured `errno`.
        case system(Error_Primitives.Error.Code)

        /// An error code outside the POSIX-specified set.
        case unknown(Int32)
    }
}

// MARK: - Code Mapping

extension ISO_9945.Kernel.Socket.Address.Info.Error {
    /// Creates a typed error from a `getaddrinfo` return code.
    ///
    /// Must be constructed immediately after the failing call so that
    /// `EAI_SYSTEM` captures the correct `errno`.
    ///
    /// - Parameter code: The nonzero `getaddrinfo` return code.
    public init(code: Int32) {
        switch code {
        case EAI_AGAIN: self = .again
        case EAI_BADFLAGS: self = .badFlags
        case EAI_FAIL: self = .fail
        case EAI_FAMILY: self = .family
        case EAI_MEMORY: self = .memory
        case EAI_NONAME: self = .noName
        case EAI_OVERFLOW: self = .overflow
        case EAI_SERVICE: self = .service
        case EAI_SOCKTYPE: self = .socketType
        case EAI_SYSTEM: self = .system(.captureErrno())
        default: self = .unknown(code)
        }
    }

    /// The platform `EAI_*` code for this error.
    public var code: Int32 {
        switch self {
        case .again: EAI_AGAIN
        case .badFlags: EAI_BADFLAGS
        case .fail: EAI_FAIL
        case .family: EAI_FAMILY
        case .memory: EAI_MEMORY
        case .noName: EAI_NONAME
        case .overflow: EAI_OVERFLOW
        case .service: EAI_SERVICE
        case .socketType: EAI_SOCKTYPE
        case .system: EAI_SYSTEM
        case .unknown(let code): code
        }
    }
}

// MARK: - Message

extension ISO_9945.Kernel.Socket.Address.Info.Error {
    /// The platform's description of this error (`gai_strerror`).
    public var message: String {
        guard let text = unsafe gai_strerror(code) else {
            return "Unknown host-resolution error \(code)"
        }
        return unsafe String(cString: text)
    }
}

// MARK: - CustomStringConvertible

extension ISO_9945.Kernel.Socket.Address.Info.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .system(let errno): "\(message): \(errno)"
        default: message
        }
    }
}
