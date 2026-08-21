@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Socket {

    public enum Name {}
}

extension ISO_9945.Kernel.Socket.Name {

    public static func local(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) {
        try local(fd: descriptor._rawValue)
    }

    public static func peer(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) {
        try peer(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.Socket.Name {

    internal static func local(
        fd: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

        let rc = unsafe storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getsockname(fd, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return (address: storage, length: ISO_9945.Kernel.Socket.Address.Length(addrLen))
    }

    internal static func peer(
        fd: Int32
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) {
        var storage = ISO_9945.Kernel.Socket.Address.Storage()
        var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

        let rc = unsafe storage.withUnsafeMutableBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe getpeername(fd, sockaddrPtr, &addrLen)
        }

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return (address: storage, length: ISO_9945.Kernel.Socket.Address.Length(addrLen))
    }
}
