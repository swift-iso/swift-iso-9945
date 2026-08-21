@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Attributes {

    public static func set(
        _ permissions: ISO_9945.Kernel.File.Permissions,
        at path: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _set(permissions, path: cString)
        }
    }

    @usableFromInline
    internal static func _set(
        _ permissions: ISO_9945.Kernel.File.Permissions,
        path: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.chmod(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.chmod(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.chmod(cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Attributes {

    @_spi(Syscall)
    public static func set(
        _ permissions: ISO_9945.Kernel.File.Permissions,
        fd: Int32
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fchmod(fd, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = unsafe Musl.fchmod(fd, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fchmod(fd, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Attributes {

    public static func set(
        _ permissions: ISO_9945.Kernel.File.Permissions,
        on descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(Error) {
        try set(permissions, fd: descriptor._rawValue)
    }
}

extension ISO_9945.Kernel.File.Attributes.Error {

    @usableFromInline
    internal static func current() -> Self {
        let code = Error_Primitives.Error.Code.current()
        switch code {
        case .ENOENT:
            return .path(.notFound)

        case .ENAMETOOLONG:
            return .path(.tooLong)

        case .ELOOP:
            return .path(.loop)

        case .EACCES:
            return .permission(.denied)

        case .EPERM:
            return .permission(.notPermitted)

        case .EROFS:
            return .permission(.readOnlyFilesystem)

        case .EIO:
            return .io(.hardware)

        default:
            return .platform(Error_Primitives.Error(code: code))
        }
    }
}
