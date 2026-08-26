@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Directory.Create {

    public static func create(
        _ path: borrowing Path.Borrowed,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(
            rawValue: 0o755
        )
    ) throws(Error) {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe _create(ptr, permissions: permissions)
        }
    }

    @usableFromInline
    internal static func _create(
        _ path: UnsafePointer<Path.Char>,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(
            rawValue: 0o755
        )
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            let result = unsafe Darwin.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            let result = Musl.mkdir(cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            let result = Glibc.mkdir(cPath, mode_t(permissions.rawValue))
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    @_spi(Syscall)
    public static func mkdirat(
        descriptor: Int32,
        path: UnsafePointer<Path.Char>,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(
            rawValue: 0o755
        )
    ) -> Int32 {
        let cPath = unsafe UnsafePointer<CChar>(path)

        #if canImport(Darwin)
            return unsafe Darwin.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Musl)
            return Musl.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #elseif canImport(Glibc)
            return Glibc.mkdirat(descriptor, cPath, mode_t(permissions.rawValue))
        #else
            #error(
                "ISO_9945.Kernel.Directory.Create.mkdirat: unsupported platform (no Darwin, Glibc, or Musl)"
            )
        #endif
    }

    public static func create(
        _ path: borrowing Path.Borrowed,
        relativeTo descriptor: borrowing ISO_9945.Kernel.Descriptor,
        permissions: ISO_9945.Kernel.File.Permissions = ISO_9945.Kernel.File.Permissions(
            rawValue: 0o755
        )
    ) throws(Error) {
        let raw = descriptor._rawValue
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            let result = unsafe Self.mkdirat(descriptor: raw, path: ptr, permissions: permissions)
            guard result == 0 else {
                throw Error.current()
            }
        }
    }
}

extension ISO_9945.Kernel.Directory.Create {
    public typealias Error = ISO_9945.Kernel.Directory.Create.Error
}

extension ISO_9945.Kernel.Directory.Create.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES, .EPERM:
            return .permission

        case .EEXIST:
            return .exists

        case .ENOTDIR:
            return .notDirectory

        case .EROFS:
            return .readOnly

        case .ENOSPC:
            return .noSpace

        case .ELOOP:
            return .loop

        case .ENAMETOOLONG:
            return .nameTooLong

        default:
            return .platform(Error.Error(code: code))
        }
    }
}
