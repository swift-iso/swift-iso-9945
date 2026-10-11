#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {

    public struct IPv4: Sendable, Equatable {
        internal var cValue: sockaddr_in

        public init(address: UInt32 = 0, port: UInt16 = 0) {
            self.cValue = sockaddr_in()
            self.cValue.sin_family = sa_family_t(AF_INET)
            self.cValue.sin_port = port.bigEndian
            self.cValue.sin_addr.s_addr = address
            #if canImport(Darwin)

                self.cValue.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
            #endif
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv4 {

    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .inet
    }

    public var port: UInt16 {
        get { UInt16(bigEndian: cValue.sin_port) }
        set { cValue.sin_port = newValue.bigEndian }
    }

    public var address: UInt32 {
        get { cValue.sin_addr.s_addr }
        set { cValue.sin_addr.s_addr = newValue }
    }

    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_in>.size))
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv4 {

    public static func any(port: UInt16) -> Self {
        Self(address: UInt32(INADDR_ANY).bigEndian, port: port)
    }

    public static func loopback(port: UInt16) -> Self {
        Self(address: UInt32(INADDR_LOOPBACK).bigEndian, port: port)
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv4 {

    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        withUnsafePointer(to: cValue) { src in
            withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_in>.size)
            }
        }
        return result
    }
}

extension ISO_9945.Kernel.Socket.Address.IPv4 {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.cValue.sin_port == rhs.cValue.sin_port
            && lhs.cValue.sin_addr.s_addr == rhs.cValue.sin_addr.s_addr
    }
}
