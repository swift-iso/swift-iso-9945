@_spi(Syscall) import ISO_9945_Core

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    internal import Darwin
#elseif os(Linux)
    #if canImport(Musl)
        internal import Musl
    #else
        internal import Glibc
    #endif
#else
    #error("ISO_9945.Kernel.IO.Read: unsupported platform")
#endif

extension ISO_9945.Kernel.IO.Read {

    internal static func read(
        fd: Int32,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            return try Syscall.require(
                unsafe Darwin.read(fd, baseAddress, buffer.count),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif os(Linux)
            #if canImport(Musl)
                return try Syscall.require(
                    unsafe Musl.read(fd, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #else
                return try Syscall.require(
                    unsafe Glibc.read(fd, baseAddress, buffer.count),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        #else
            #error("ISO_9945.Kernel.IO.Read.read: unsupported platform")
        #endif
    }

    internal static func pread(
        fd: Int32,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard let baseAddress = buffer.baseAddress else {
            return 0
        }
        #if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
            return try Syscall.require(
                unsafe Darwin.pread(fd, baseAddress, buffer.count, off_t(offset.underlying)),
                .nonNegative,
                orThrow: Error.current()
            )
        #elseif os(Linux)
            #if canImport(Musl)
                return try Syscall.require(
                    unsafe Musl.pread(fd, baseAddress, buffer.count, off_t(offset.underlying)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #else
                return try Syscall.require(
                    unsafe Glibc.pread(fd, baseAddress, buffer.count, off_t(offset.underlying)),
                    .nonNegative,
                    orThrow: Error.current()
                )
            #endif
        #else
            #error("ISO_9945.Kernel.IO.Read.pread: unsupported platform")
        #endif
    }
}

extension ISO_9945.Kernel.IO.Read {

    @_disfavoredOverload
    public static func read(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe read(fd: descriptor._rawValue, into: buffer)
    }

    @_disfavoredOverload
    public static func pread(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        into buffer: UnsafeMutableRawBufferPointer,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe pread(fd: descriptor._rawValue, into: buffer, at: offset)
    }
}

extension ISO_9945.Kernel.IO.Read {

    @_disfavoredOverload
    public static func read(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        into output: inout Swift.OutputSpan<Byte>
    ) throws(Error) -> Int {
        try unsafe output.withUnsafeMutableBufferPointer {
            (
                buffer: UnsafeMutableBufferPointer<Byte>,
                initializedCount: inout Int
            ) throws(Error) -> Int in
            let rawBuffer = UnsafeMutableRawBufferPointer(buffer)
            let count = try unsafe read(
                descriptor,
                into: UnsafeMutableRawBufferPointer(rebasing: rawBuffer[initializedCount...])
            )
            initializedCount += count
            return count
        }
    }

    @_disfavoredOverload
    public static func read(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        into span: inout MutableSpan<Byte>
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes {
            (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try unsafe read(descriptor, into: buffer)
        }
    }

    @_disfavoredOverload
    public static func pread(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        into span: inout MutableSpan<Byte>,
        at offset: ISO_9945.Kernel.File.Offset
    ) throws(Error) -> Int {
        try span.withUnsafeMutableBytes {
            (buffer: UnsafeMutableRawBufferPointer) throws(Error) -> Int in
            try unsafe pread(descriptor, into: buffer, at: offset)
        }
    }
}

extension ISO_9945.Kernel.IO.Read.Error {

    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        if let handleError = ISO_9945.Kernel.Descriptor.Validity.Error(code: code) {
            return .handle(handleError)
        }
        if let blockingError = ISO_9945.Kernel.IO.Blocking.Error(code: code) {
            return .blocking(blockingError)
        }
        return .platform(Error_Primitives.Error(code: code))
    }
}
