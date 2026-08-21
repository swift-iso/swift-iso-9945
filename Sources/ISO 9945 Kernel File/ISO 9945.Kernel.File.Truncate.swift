@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File {

    public enum Truncate {}
}

extension ISO_9945.Kernel.File.Truncate {

    @_spi(Syscall)
    public static func truncate(
        fd: Int32,
        to length: ISO_9945.Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        let rc = ftruncate(fd, off_t(length.underlying))

        guard rc == 0 else {
            throw Error_Primitives.Error.current(operation: "ftruncate")
        }
    }
}

extension ISO_9945.Kernel.File.Truncate {

    public static func truncate(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        to length: ISO_9945.Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        try truncate(fd: descriptor._rawValue, to: length)
    }

    public static func truncate(
        path: UnsafePointer<CChar>,
        to length: ISO_9945.Kernel.File.Size
    ) throws(Error_Primitives.Error) {
        let rc = unsafe platformTruncate(path, off_t(length.underlying))

        guard rc == 0 else {
            throw Error_Primitives.Error.current(operation: "truncate")
        }
    }
}

private func platformTruncate(_ path: UnsafePointer<CChar>, _ length: off_t) -> Int32 {
    #if canImport(Darwin)
        unsafe Darwin.truncate(path, length)
    #elseif canImport(Glibc)
        unsafe Glibc.truncate(path, length)
    #elseif canImport(Musl)
        unsafe Musl.truncate(path, length)
    #endif
}
