@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public enum Accept {}
}

extension ISO_9945.Kernel.Socket.Accept {

    public static func accept(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> Result {
        try accept(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.Socket.Accept {

    internal static func accept(fd: Int32) throws(ISO_9945.Kernel.Socket.Error) -> Result {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

        let acceptedFd = unsafe storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe platformAccept(fd, sockaddrPtr, &addrLen)
        }

        guard acceptedFd >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return Result(
            descriptor: ISO_9945.Kernel.Socket.Descriptor(_raw: acceptedFd),
            address: storage,
            length: ISO_9945.Kernel.Socket.Address.Length(addrLen)
        )
    }
}

private func platformAccept(
    _ fd: Int32,
    _ addr: UnsafeMutablePointer<sockaddr>,
    _ len: UnsafeMutablePointer<socklen_t>
) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.accept(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.accept(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.accept(fd, addr, len)
    #endif
}
