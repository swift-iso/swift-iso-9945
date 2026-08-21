@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Seek {

    @discardableResult
    @_spi(Syscall)
    public static func seek(
        fd: Int32,
        offset: Int64,
        whence: Whence
    ) throws(Error) -> Int64 {
        #if canImport(Darwin)
            let result = Darwin.lseek(fd, offset, whence.rawValue)
        #elseif canImport(Musl)
            let result = unsafe Musl.lseek(fd, offset, whence.rawValue)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.lseek(fd, off_t(offset), whence.rawValue)
        #endif

        guard result >= 0 else {
            throw Error.current()
        }
        return Int64(result)
    }

    @_spi(Syscall)
    public static func tell(fd: Int32) throws(Error) -> Int64 {
        try seek(fd: fd, offset: 0, whence: .current)
    }
}

extension ISO_9945.Kernel.File.Seek {

    @discardableResult
    public static func seek(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        offset: Int64,
        whence: Whence
    ) throws(Error) -> Int64 {
        try seek(fd: descriptor._rawValue, offset: offset, whence: whence)
    }

    public static func tell(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(Error) -> Int64 {
        try tell(fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.File.Seek.Whence {

    public static let start = Self(rawValue: SEEK_SET)

    public static let current = Self(rawValue: SEEK_CUR)

    public static let end = Self(rawValue: SEEK_END)
}

extension ISO_9945.Kernel.File.Seek {
    public typealias Error = ISO_9945.Kernel.File.Seek.Error
}

extension ISO_9945.Kernel.File.Seek.Error {

    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .EBADF:
            return .invalidDescriptor

        case .EINVAL:
            return .invalidSeek

        case .ESPIPE:
            return .notSeekable

        case .EOVERFLOW:
            return .overflow

        default:
            return .platform(code: code)
        }
    }
}
