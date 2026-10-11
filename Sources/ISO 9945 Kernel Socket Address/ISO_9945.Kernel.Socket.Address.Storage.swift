#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address {

    public struct Storage: Sendable {
        internal var cValue: sockaddr_storage

        public init() {
            self.cValue = sockaddr_storage()
        }
    }
}

extension ISO_9945.Kernel.Socket.Address.Storage {

    public var family: ISO_9945.Kernel.Socket.Address.Family {
        ISO_9945.Kernel.Socket.Address.Family(rawValue: Int32(cValue.ss_family))
    }

    public static var size: ISO_9945.Kernel.Socket.Address.Length {
        ISO_9945.Kernel.Socket.Address.Length(UInt(MemoryLayout<sockaddr_storage>.size))
    }
}

extension ISO_9945.Kernel.Socket.Address.Storage {

    public func withUnsafeBytes<R, E: Swift.Error>(
        _ body: (UnsafeRawPointer, UInt32) throws(E) -> R
    ) throws(E) -> R {
        try Swift.withUnsafeBytes(of: cValue) {
            (buffer: UnsafeRawBufferPointer) throws(E) -> R in
            try unsafe body(buffer.baseAddress!, UInt32(buffer.count))
        }
    }

    public mutating func withUnsafeMutableBytes<R, E: Swift.Error>(
        _ body: (UnsafeMutableRawPointer, UInt32) throws(E) -> R
    ) throws(E) -> R {
        try Swift.withUnsafeMutableBytes(of: &cValue) {
            (buffer: UnsafeMutableRawBufferPointer) throws(E) -> R in
            try unsafe body(buffer.baseAddress!, UInt32(buffer.count))
        }
    }
}
