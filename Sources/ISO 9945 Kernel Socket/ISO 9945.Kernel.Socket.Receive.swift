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
    #error(
        "ISO_9945.Kernel.Socket.Receive: unsupported platform (no Darwin, Glibc, Musl, or Android)"
    )
#endif

extension ISO_9945.Kernel.Socket {

    public enum Receive {}
}

extension ISO_9945.Kernel.Socket.Receive {

    public static func receive(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try receive(fd: descriptor._rawValue, into: &span, options: options)
    }

    public static func from(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        count: Int, address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) {
        try from(fd: descriptor._rawValue, into: &span, options: options)
    }

    public static func message(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try message(fd: descriptor._rawValue, header: &header, options: options)
    }
}

extension ISO_9945.Kernel.Socket.Receive {

    internal static func receive(
        fd: Int32,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try span.withUnsafeMutableBytes {
            (buffer: UnsafeMutableRawBufferPointer) throws(ISO_9945.Kernel.Socket.Error) -> Int in

            var zero: UInt8 = 0
            let result = withUnsafeMutablePointer(to: &zero) { fallback in
                unsafe platformReceive(
                    fd,
                    buffer.baseAddress ?? UnsafeMutableRawPointer(fallback),
                    buffer.count,
                    options.rawValue
                )
            }
            guard result >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }
            return result
        }
    }

    internal static func from(
        fd: Int32,
        into span: inout MutableSpan<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> (
        count: Int, address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) {
        try span.withUnsafeMutableBytes {
            (
                buffer: UnsafeMutableRawBufferPointer
            ) throws(ISO_9945.Kernel.Socket.Error) -> (
                count: Int, address: ISO_9945.Kernel.Socket.Address.Storage,
                addressLength: ISO_9945.Kernel.Socket.Address.Length
            ) in

            var storage = ISO_9945.Kernel.Socket.Address.Storage()
            var addrLen = socklen_t(ISO_9945.Kernel.Socket.Address.Storage.size.underlying.rawValue)

            var zero: UInt8 = 0
            let count = withUnsafeMutablePointer(to: &zero) { fallback in
                unsafe storage.withUnsafeMutableBytes { ptr, _ in
                    let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
                    return unsafe recvfrom(
                        fd,
                        buffer.baseAddress ?? UnsafeMutableRawPointer(fallback),
                        buffer.count,
                        options.rawValue,
                        sockaddrPtr,
                        &addrLen
                    )
                }
            }

            guard count >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }

            return (
                count: count, address: storage,
                addressLength: ISO_9945.Kernel.Socket.Address.Length(addrLen)
            )
        }
    }

    internal static func message(
        fd: Int32,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        let result = unsafe recvmsg(
            fd,
            &header.cValue,
            options.rawValue
        )

        guard result >= 0 else {
            throw ISO_9945.Kernel.Socket.Error.current()
        }

        return result
    }
}

private func platformReceive(
    _ fd: Int32,
    _ buf: UnsafeMutableRawPointer,
    _ len: Int,
    _ flags: Int32
) -> Int {
    #if canImport(Darwin)
        unsafe Darwin.recv(fd, buf, len, flags)
    #elseif canImport(Glibc)
        unsafe Glibc.recv(fd, buf, len, flags)
    #elseif canImport(Musl)
        unsafe Musl.recv(fd, buf, len, flags)
    #elseif canImport(Android)
        unsafe Android.recv(fd, buf, len, flags)
    #else
        #error(
            "ISO_9945.Kernel.Socket.Receive: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
