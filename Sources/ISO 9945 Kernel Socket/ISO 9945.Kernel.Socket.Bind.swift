@_spi(Syscall) public import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#elseif canImport(Android)
    internal import Android
#else
    #error("ISO_9945.Kernel.Socket.Bind: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

extension ISO_9945.Kernel.Socket {

    public enum Bind {}
}

extension ISO_9945.Kernel.Socket.Bind {

    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address, length: length)
    }

    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.IPv4
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }

    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.IPv6
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }

    public static func bind(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        address: ISO_9945.Kernel.Socket.Address.Unix
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: descriptor._rawValue, address: address)
    }
}

extension ISO_9945.Kernel.Socket.Bind {

    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Storage,
        length: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) {
        let rc = unsafe address.withUnsafeBytes { ptr, _ in
            let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
            return unsafe platformBind(
                fd,
                sockaddrPtr,
                socklen_t(length.underlying.rawValue)
            )
        }

        guard rc == 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }
    }

    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv4
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv4.size)
    }

    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.IPv6
    ) throws(ISO_9945.Kernel.Socket.Error) {
        try bind(fd: fd, address: address.storage, length: ISO_9945.Kernel.Socket.Address.IPv6.size)
    }

    internal static func bind(
        fd: Int32,
        address: ISO_9945.Kernel.Socket.Address.Unix
    ) throws(ISO_9945.Kernel.Socket.Error) {

        try bind(fd: fd, address: address.storage, length: address.length)
    }
}

private func platformBind(
    _ fd: Int32,
    _ addr: UnsafePointer<sockaddr>,
    _ len: socklen_t
) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.bind(fd, addr, len)
    #elseif canImport(Glibc)
        unsafe Glibc.bind(fd, addr, len)
    #elseif canImport(Musl)
        unsafe Musl.bind(fd, addr, len)
    #elseif canImport(Android)
        unsafe Android.bind(fd, addr, len)
    #else
        #error(
            "ISO_9945.Kernel.Socket.Bind: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
