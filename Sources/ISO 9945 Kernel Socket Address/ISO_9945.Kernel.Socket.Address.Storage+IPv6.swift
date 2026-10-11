#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket.Address.Storage {

    public var ipv6: ISO_9945.Kernel.Socket.Address.IPv6? {
        guard family == .inet6 else { return nil }
        var result = ISO_9945.Kernel.Socket.Address.IPv6()
        unsafe withUnsafeBytes { source, capacity in
            Swift.withUnsafeMutableBytes(of: &result.cValue) { destination in
                let count = min(MemoryLayout<sockaddr_in6>.size, Int(capacity))
                unsafe destination.copyMemory(
                    from: UnsafeRawBufferPointer(start: source, count: count)
                )
            }
        }
        return result
    }
}
