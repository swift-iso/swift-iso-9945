#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Info {

    @safe
    public struct List: ~Copyable {

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

extension ISO_9945.Kernel.Socket.Address.Info.List {

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

        let code = host.withCString { hostPointer in
            unsafe withService(service) { servicePointer in
                withUnsafePointer(to: constraints) { hintsPointer in
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

    private static func withService<R>(
        _ service: String?,
        _ body: (UnsafePointer<CChar>?) -> R
    ) -> R {
        guard let service else { return body(nil) }
        return service.withCString { pointer in unsafe body(pointer) }
    }
}

extension ISO_9945.Kernel.Socket.Address.Info.List {

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
