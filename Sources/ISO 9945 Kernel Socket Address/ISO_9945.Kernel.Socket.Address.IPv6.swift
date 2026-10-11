#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {

    public struct IPv6: Sendable {
        internal var cValue: sockaddr_in6

        public init(port: UInt16 = 0) {
            self.cValue = sockaddr_in6()
            self.cValue.sin6_family = sa_family_t(AF_INET6)
            self.cValue.sin6_port = port.bigEndian
            #if canImport(Darwin)

                self.cValue.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            #endif
        }

        public init(
            address: (
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8,
                UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8
            ),
            port: UInt16 = 0,
            flowInfo: UInt32 = 0,
            scopeId: UInt32 = 0
        ) {
            self.cValue = sockaddr_in6()
            self.cValue.sin6_family = sa_family_t(AF_INET6)
            self.cValue.sin6_port = port.bigEndian
            self.cValue.sin6_flowinfo = flowInfo
            self.cValue.sin6_scope_id = scopeId
            #if canImport(Darwin)

                self.cValue.sin6_len = UInt8(MemoryLayout<sockaddr_in6>.size)
            #endif

            withUnsafeMutableBytes(of: &self.cValue.sin6_addr) { dst in
                withUnsafeBytes(of: address) { src in
                    unsafe dst.copyMemory(from: src)
                }
            }
        }

        public init(
            segments: (
                UInt16, UInt16, UInt16, UInt16,
                UInt16, UInt16, UInt16, UInt16
            ),
            port: UInt16 = 0,
            flowInfo: UInt32 = 0,
            scopeId: UInt32 = 0
        ) {
            self.init(
                address: (
                    UInt8(truncatingIfNeeded: segments.0 >> 8),
                    UInt8(truncatingIfNeeded: segments.0),
                    UInt8(truncatingIfNeeded: segments.1 >> 8),
                    UInt8(truncatingIfNeeded: segments.1),
                    UInt8(truncatingIfNeeded: segments.2 >> 8),
                    UInt8(truncatingIfNeeded: segments.2),
                    UInt8(truncatingIfNeeded: segments.3 >> 8),
                    UInt8(truncatingIfNeeded: segments.3),
                    UInt8(truncatingIfNeeded: segments.4 >> 8),
                    UInt8(truncatingIfNeeded: segments.4),
                    UInt8(truncatingIfNeeded: segments.5 >> 8),
                    UInt8(truncatingIfNeeded: segments.5),
                    UInt8(truncatingIfNeeded: segments.6 >> 8),
                    UInt8(truncatingIfNeeded: segments.6),
                    UInt8(truncatingIfNeeded: segments.7 >> 8),
                    UInt8(truncatingIfNeeded: segments.7)
                ),
                port: port,
                flowInfo: flowInfo,
                scopeId: scopeId
            )
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv6 {

    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .inet6
    }

    public var port: UInt16 {
        get { UInt16(bigEndian: cValue.sin6_port) }
        set { cValue.sin6_port = newValue.bigEndian }
    }

    public var flowInfo: UInt32 {
        get { cValue.sin6_flowinfo }
        set { cValue.sin6_flowinfo = newValue }
    }

    public var scopeId: UInt32 {
        get { cValue.sin6_scope_id }
        set { cValue.sin6_scope_id = newValue }
    }

    public var segments:
        (
            UInt16, UInt16, UInt16, UInt16,
            UInt16, UInt16, UInt16, UInt16
        )
    {
        withUnsafeBytes(of: cValue.sin6_addr) { bytes in
            func segment(_ offset: Int) -> UInt16 {
                let high = unsafe UInt16(bytes[offset])
                let low = unsafe UInt16(bytes[offset + 1])
                return high << 8 | low
            }
            return (
                segment(0), segment(2), segment(4), segment(6),
                segment(8), segment(10), segment(12), segment(14)
            )
        }
    }

    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_in6>.size))
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv6 {

    public static func any(port: UInt16) -> Self {
        Self(port: port)
    }

    public static func loopback(port: UInt16) -> Self {
        var addr = Self(port: port)
        addr.cValue.sin6_addr = in6addr_loopback
        return addr
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv6 {

    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        withUnsafePointer(to: cValue) { src in
            withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_in6>.size)
            }
        }
        return result
    }
}
