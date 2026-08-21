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
    #error("ISO_9945.Kernel.Socket.Send: unsupported platform (no Darwin, Glibc, Musl, or Android)")
#endif

extension ISO_9945.Kernel.Socket {

    public enum Send {}
}

extension ISO_9945.Kernel.Socket.Send {

    public static func send(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try send(fd: descriptor._rawValue, from: span, options: options)
    }

    public static func to(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = [],
        address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try to(
            fd: descriptor._rawValue,
            from: span,
            options: options,
            address: address,
            addressLength: addressLength
        )
    }

    public static func message(
        _ descriptor: borrowing ISO_9945.Kernel.Socket.Descriptor,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try message(fd: descriptor._rawValue, header: &header, options: options)
    }
}

extension ISO_9945.Kernel.Socket.Send {

    internal static func send(
        fd: Int32,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try span.withUnsafeBytes { buffer throws(ISO_9945.Kernel.Socket.Error) -> Int in

            var zero: UInt8 = 0
            let result = withUnsafePointer(to: &zero) { fallback in
                unsafe platformSend(
                    fd,
                    buffer.baseAddress ?? UnsafeRawPointer(fallback),
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

    internal static func to(
        fd: Int32,
        from span: Swift.Span<Byte>,
        options: ISO_9945.Kernel.Socket.Message.Options = [],
        address: ISO_9945.Kernel.Socket.Address.Storage,
        addressLength: ISO_9945.Kernel.Socket.Address.Length
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        try span.withUnsafeBytes { buffer throws(ISO_9945.Kernel.Socket.Error) -> Int in

            var zero: UInt8 = 0
            let result = withUnsafePointer(to: &zero) { fallback in
                unsafe address.withUnsafeBytes { ptr, _ in
                    let sockaddrPtr = unsafe ptr.assumingMemoryBound(to: sockaddr.self)
                    return unsafe sendto(
                        fd,
                        buffer.baseAddress ?? UnsafeRawPointer(fallback),
                        buffer.count,
                        options.rawValue,
                        sockaddrPtr,
                        socklen_t(addressLength.underlying.rawValue)
                    )
                }
            }
            guard result >= 0 else {
                throw ISO_9945.Kernel.Socket.Error.current()
            }
            return result
        }
    }

    internal static func message(
        fd: Int32,
        header: inout ISO_9945.Kernel.Socket.Message.Header,
        options: ISO_9945.Kernel.Socket.Message.Options = []
    ) throws(ISO_9945.Kernel.Socket.Error) -> Int {
        let result = unsafe sendmsg(
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

private func platformSend(
    _ fd: Int32,
    _ buf: UnsafeRawPointer,
    _ len: Int,
    _ flags: Int32
) -> Int {
    #if canImport(Darwin)
        unsafe Darwin.send(fd, buf, len, flags)
    #elseif canImport(Glibc)
        unsafe Glibc.send(fd, buf, len, flags)
    #elseif canImport(Musl)
        unsafe Musl.send(fd, buf, len, flags)
    #elseif canImport(Android)
        unsafe Android.send(fd, buf, len, flags)
    #else
        #error(
            "ISO_9945.Kernel.Socket.Send: unsupported platform (no Darwin, Glibc, Musl, or Android)"
        )
    #endif
}
