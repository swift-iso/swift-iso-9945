@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO.Write {

    internal static func write(
        fd: Int32,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.write(fd, baseAddress, buffer.count)
        #elseif canImport(Musl)
            let result = unsafe Musl.write(fd, baseAddress, buffer.count)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.write(fd, baseAddress, buffer.count)
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }

    internal static func pwrite(
        fd: Int32,
        from buffer: UnsafeRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }

        #if canImport(Darwin)
            let result = unsafe Darwin.pwrite(
                fd,
                baseAddress,
                buffer.count,
                off_t(offset.underlying)
            )
        #elseif canImport(Musl)
            let result = unsafe Musl.pwrite(fd, baseAddress, buffer.count, off_t(offset.underlying))
        #elseif canImport(Glibc)
            let result = unsafe Glibc.pwrite(
                fd,
                baseAddress,
                buffer.count,
                off_t(offset.underlying)
            )
        #endif

        if result >= 0 {
            return result
        }

        throw Error.current()
    }
}

extension ISO_9945.Kernel.IO.Write {

    @_disfavoredOverload
    public static func write(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe write(fd: descriptor._rawValue, from: buffer)
    }

    @_disfavoredOverload
    public static func pwrite(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from buffer: UnsafeRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe pwrite(fd: descriptor._rawValue, from: buffer, at: offset)
    }
}

extension ISO_9945.Kernel.IO.Write {

    @_disfavoredOverload
    public static func write(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from span: Swift.Span<Byte>
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try unsafe write(descriptor, from: buffer)
        }
    }

    @_disfavoredOverload
    public static func pwrite(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        from span: Swift.Span<Byte>,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) throws(Error) -> Int in
            try unsafe pwrite(descriptor, from: buffer, at: offset)
        }
    }
}

extension ISO_9945.Kernel.IO.Write.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let blockingError = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
            return .blocking(blockingError)
        }
        return .platform(Error.Error(code: code))
    }
}
