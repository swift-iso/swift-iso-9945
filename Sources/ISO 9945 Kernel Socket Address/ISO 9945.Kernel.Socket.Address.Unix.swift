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

    public enum Error: Swift.Error, Sendable, Equatable {

        case pathTooLong(length: Int, capacity: Int)
    }

    internal static var pathOffset: Int {
        MemoryLayout<sockaddr_un>.offset(of: \.sun_path) ?? 2
    }

    public static var pathCapacity: Int {
        MemoryLayout<sockaddr_un>.size - pathOffset
    }

    public init(path: Swift.String) throws(Error) {
        let bytes = Array(path.utf8)
        guard bytes.count + 1 <= Self.pathCapacity else {
            throw .pathTooLong(length: bytes.count, capacity: Self.pathCapacity)
        }
        self.init()
        withUnsafeMutableBytes(of: &cValue.sun_path) { dst in
            for (index, byte) in bytes.enumerated() {
                unsafe (dst[index] = byte)
            }
            unsafe (dst[bytes.count] = 0)
        }
        #if canImport(Darwin)
            cValue.sun_len = UInt8(Self.pathOffset + bytes.count + 1)
        #endif
    }

    public var path: Swift.String {
        withUnsafeBytes(of: cValue.sun_path) { bytes in
            var length = 0
            while length < bytes.count && (unsafe bytes[length]) != 0 {
                length += 1
            }
            return unsafe Swift.String(decoding: bytes[..<length], as: UTF8.self)
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
