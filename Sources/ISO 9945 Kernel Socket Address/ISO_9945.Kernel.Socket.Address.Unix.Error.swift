#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Unix {

    public enum Error: Swift::Error, Sendable, Equatable {

        case pathTooLong(length: Int, capacity: Int)
    }

    internal static var pathOffset: Int {
        MemoryLayout<sockaddr_un>.offset(of: \.sun_path) ?? 2
    }

    public static var pathCapacity: Int {
        MemoryLayout<sockaddr_un>.size - pathOffset
    }

    public init(path: Swift::String) throws(Error) {
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

    public var path: Swift::String {
        withUnsafeBytes(of: cValue.sun_path) { bytes in
            var length = 0
            while length < bytes.count && (unsafe bytes[length]) != 0 {
                length += 1
            }
            return unsafe Swift::String(decoding: bytes[..<length], as: UTF8.self)
        }
    }
}
