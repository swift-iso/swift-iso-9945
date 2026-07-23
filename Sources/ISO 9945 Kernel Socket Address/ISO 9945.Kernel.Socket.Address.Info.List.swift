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
    /// Owned `addrinfo` chain returned by `getaddrinfo`.
    ///
    /// The list is the single owner of the platform chain: dropping the value
    /// releases it via `freeaddrinfo`, mirroring the POSIX ownership contract.
    /// The owner may be destroyed at any time after the resolving call
    /// returns — including long after a logical requester abandoned the
    /// result — so a late result is always freed exactly once.
    ///
    /// No platform pointer escapes this type; ``entries`` converts each node
    /// into an owned ``ISO_9945/Kernel/Socket/Address/Info`` value in the
    /// system resolver's original order.
    ///
    /// ## Safety Invariant
    ///
    /// `head` is either nil or the head pointer a successful `getaddrinfo`
    /// call produced, owned exclusively by this move-only value. It is never
    /// exposed, and it is freed exactly once, in `deinit`.
    @safe
    public struct List: ~Copyable {
        /// The head of the owned chain.
        private let head: UnsafeMutablePointer<addrinfo>?

        internal init(head: UnsafeMutablePointer<addrinfo>?) {
            unsafe self.head = head
        }

        deinit {
            if let head = unsafe head {
                unsafe freeaddrinfo(head)
            }
        }
    }
}

// MARK: - Resolution

extension ISO_9945.Kernel.Socket.Address.Info.List {
    /// Resolves a host (and optionally a service) into an owned address chain.
    ///
    /// Wraps `getaddrinfo`. The call honors the platform's complete
    /// resolution policy — `/etc/hosts`, NSS, search domains, and any
    /// system-specific configuration. The call blocks the calling thread and
    /// is not interruptible; callers that need cancellation dispatch it to a
    /// worker they own and abandon the logical wait instead.
    ///
    /// - Parameters:
    ///   - host: The node name or numeric address string to resolve.
    ///   - service: The service name or numeric port string, or nil.
    ///   - hints: Constraints on the returned entries.
    /// - Returns: The owned result chain, in the system resolver's order.
    /// - Throws: The typed `EAI_*` failure.
    public static func get(
        host: String,
        service: String? = nil,
        hints: ISO_9945.Kernel.Socket.Address.Info.Hints = .init()
    ) throws(ISO_9945.Kernel.Socket.Address.Info.Error) -> Self {
        var head: UnsafeMutablePointer<addrinfo>? = nil
        var constraints = unsafe addrinfo()
        unsafe constraints.ai_flags = hints.options.rawValue
        unsafe constraints.ai_family = hints.family.rawValue
        unsafe constraints.ai_socktype = hints.kind?.rawValue ?? 0
        unsafe constraints.ai_protocol = hints.protocol

        let code = unsafe host.withCString { hostPointer in
            unsafe withService(service) { servicePointer in
                unsafe withUnsafePointer(to: constraints) { hintsPointer in
                    unsafe getaddrinfo(hostPointer, servicePointer, hintsPointer, &head)
                }
            }
        }

        guard code == 0 else {
            let failure = ISO_9945.Kernel.Socket.Address.Info.Error(code: code)
            if let head = unsafe head {
                unsafe freeaddrinfo(head)
            }
            throw failure
        }
        return unsafe Self(head: head)
    }

    /// Calls `body` with the C string form of an optional service name.
    private static func withService<R>(
        _ service: String?,
        _ body: (UnsafePointer<CChar>?) -> R
    ) -> R {
        guard let service else { return body(nil) }
        return unsafe service.withCString { pointer in unsafe body(pointer) }
    }
}

// MARK: - Owned Conversion

extension ISO_9945.Kernel.Socket.Address.Info.List {
    /// The chain converted to owned entries, in the system resolver's order.
    ///
    /// Each entry copies every referenced field; the returned values remain
    /// valid after this list is destroyed.
    public var entries: [ISO_9945.Kernel.Socket.Address.Info] {
        var result: [ISO_9945.Kernel.Socket.Address.Info] = []
        var node = unsafe head
        while let current = unsafe node {
            let value = unsafe current.pointee
            unsafe result.append(
                ISO_9945.Kernel.Socket.Address.Info(
                    family: ISO_9945.Kernel.Socket.Address.Family(rawValue: value.ai_family),
                    kind: ISO_9945.Kernel.Socket.Kind(rawValue: value.ai_socktype),
                    protocol: value.ai_protocol,
                    address: Self.address(of: value),
                    length: ISO_9945.Kernel.Socket.Address.Length(UInt32(value.ai_addrlen)),
                    canonical: value.ai_canonname.map { unsafe String(cString: $0) }
                )
            )
            unsafe node = value.ai_next
        }
        return result
    }

    /// Copies one node's socket address into owned storage.
    private static func address(of value: addrinfo) -> ISO_9945.Kernel.Socket.Address.Storage {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        guard let source = unsafe value.ai_addr else { return storage }
        unsafe storage.withUnsafeMutableBytes { destination, capacity in
            let count = unsafe min(Int(value.ai_addrlen), Int(capacity))
            unsafe destination.copyMemory(from: UnsafeRawPointer(source), byteCount: count)
        }
        return storage
    }
}
