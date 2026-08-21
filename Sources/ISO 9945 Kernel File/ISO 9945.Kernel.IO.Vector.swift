@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.IO {

    public enum Vector {}
}

extension ISO_9945.Kernel.IO.Vector {

    fileprivate static var iovMax: Int {
        let value = sysconf(Int32(_SC_IOV_MAX))
        return value > 0 ? Int(value) : 16
    }
}

extension ISO_9945.Kernel.IO.Vector {

    @_spi(Syscall)
    public static func read(
        fd: Int32,
        buffers: [Segment]
    ) throws(ISO_9945.Kernel.IO.Read.Error) -> Int {

        guard unsafe !buffers.isEmpty, unsafe buffers.count <= Self.iovMax else {
            throw .platform(Error_Primitives.Error(code: .posix(EINVAL)))
        }
        let iovecs = unsafe buffers.map { unsafe $0.cValue }
        let result = iovecs.withUnsafeBufferPointer { buf in
            unsafe readv(fd, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw ISO_9945.Kernel.IO.Read.Error.current()
        }

        return result
    }
}

extension ISO_9945.Kernel.IO.Vector {

    @_spi(Syscall)
    public static func write(
        fd: Int32,
        buffers: [Segment]
    ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {

        guard unsafe !buffers.isEmpty, unsafe buffers.count <= Self.iovMax else {
            throw .platform(Error_Primitives.Error(code: .posix(EINVAL)))
        }
        let iovecs = unsafe buffers.map { unsafe $0.cValue }
        let result = iovecs.withUnsafeBufferPointer { buf in
            unsafe writev(fd, buf.baseAddress!, Int32(buf.count))
        }

        guard result >= 0 else {
            throw ISO_9945.Kernel.IO.Write.Error.current()
        }

        return result
    }
}

extension ISO_9945.Kernel.IO.Vector {

    public static func read(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        buffers: [Segment]
    ) throws(ISO_9945.Kernel.IO.Read.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe read(fd: descriptor._rawValue, buffers: buffers)
    }

    public static func write(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        buffers: [Segment]
    ) throws(ISO_9945.Kernel.IO.Write.Error) -> Int {
        guard descriptor.isValid else {
            throw .handle(.invalid)
        }
        return try unsafe write(fd: descriptor._rawValue, buffers: buffers)
    }
}
