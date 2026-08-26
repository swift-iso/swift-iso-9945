@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Delete {

    public static func delete(_ path: borrowing Path.Borrowed) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _delete(cString)
        }
    }

    @usableFromInline
    internal static func _delete(_ path: UnsafePointer<Path.Char>) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.unlink(cPath)
        #elseif canImport(Musl)
            let result = Musl.unlink(cPath)
        #elseif canImport(Glibc)
            let result = Glibc.unlink(cPath)
        #endif

        try Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

extension ISO_9945.Kernel.File.Delete {

    @_spi(Syscall)
    public static func delete(
        fd: Int32,
        path: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.unlinkat(fd, cPath, flags)
        #elseif canImport(Musl)
            let result = unsafe Musl.unlinkat(fd, cPath, flags)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.unlinkat(fd, cPath, flags)
        #endif

        try Syscall.require(result, .equals(0), orThrow: Error.current())
    }
}

extension ISO_9945.Kernel.File.Delete {

    @usableFromInline
    internal static func _delete(
        relativeTo descriptor: borrowing ISO_9945.Kernel.Descriptor,
        path: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        try unsafe delete(fd: descriptor._rawValue, path: path, flags: flags)
    }
}

extension ISO_9945.Kernel.File.Delete {
    public typealias Error = ISO_9945.Kernel.File.Delete.Error
}

extension ISO_9945.Kernel.File.Delete.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES, .EPERM:
            return .permission

        case .EISDIR:
            return .isDirectory

        case .ENOTDIR:
            return .notDirectory

        case .EROFS:
            return .readOnly

        case .EBUSY:
            return .busy

        case .ELOOP:
            return .loop

        case .ENAMETOOLONG:
            return .nameTooLong

        default:
            return .platform(Error.Error(code: code))
        }
    }
}
