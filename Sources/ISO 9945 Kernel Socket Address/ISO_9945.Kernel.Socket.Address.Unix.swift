#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {

    public struct Unix: Sendable {
        internal var cValue: sockaddr_un

        public init() {
            self.cValue = sockaddr_un()
            self.cValue.sun_family = sa_family_t(AF_UNIX)
            #if canImport(Darwin)
                self.cValue.sun_len = UInt8(Self.pathOffset + 1)
            #endif
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.Unix {

    public var family: ISO_9945.Kernel.Socket.Address.Family {
        .unix
    }

    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_un>.size))
    }

    public var length: ISO_9945.Kernel.Socket.Address.Length {
        let pathLength = withUnsafeBytes(of: cValue.sun_path) { bytes in
            var length = 0
            while length < bytes.count && (unsafe bytes[length]) != 0 {
                length += 1
            }
            return length
        }
        return ISO_9945.Kernel.Socket.Address.Length(UInt(Self.pathOffset + pathLength + 1))
    }
}

extension ISO_9945.Kernel.Socket.Address.Unix {

    public var storage: ISO_9945.Kernel.Socket.Address.Storage {
        var result = ISO_9945.Kernel.Socket.Address.Storage()
        withUnsafePointer(to: cValue) { src in
            withUnsafeMutablePointer(to: &result.cValue) { dst in
                unsafe UnsafeMutableRawPointer(dst)
                    .copyMemory(from: src, byteCount: MemoryLayout<sockaddr_un>.size)
            }
        }
        return result
    }
}
