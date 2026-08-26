@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Chown {

    public static func chown(
        path: borrowing Path.Borrowed,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _chown(path: cString, uid: uid, gid: gid)
        }
    }

    @usableFromInline
    internal static func _chown(
        path: UnsafePointer<Path.Char>,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.chown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = Musl.chown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = Glibc.chown(cPath, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    public static func lchown(
        path: borrowing Path.Borrowed,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _lchown(path: cString, uid: uid, gid: gid)
        }
    }

    @usableFromInline
    internal static func _lchown(
        path: UnsafePointer<Path.Char>,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        let cPath = unsafe UnsafePointer<CChar>(path)
        #if canImport(Darwin)
            let result = unsafe Darwin.lchown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = Musl.lchown(cPath, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = Glibc.lchown(cPath, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Chown {

    @_spi(Syscall)
    public static func fchown(
        fd: Int32,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        #if canImport(Darwin)
            let result = Darwin.fchown(fd, uid.underlying, gid.underlying)
        #elseif canImport(Musl)
            let result = unsafe Musl.fchown(fd, uid.underlying, gid.underlying)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.fchown(fd, uid.underlying, gid.underlying)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Chown {

    public static func fchown(
        _ descriptor: borrowing ISO_9945.Kernel.Descriptor,
        uid: ISO_9945.Kernel.User.ID,
        gid: ISO_9945.Kernel.Group.ID
    ) throws(Error) {
        try fchown(fd: descriptor._rawValue, uid: uid, gid: gid)
    }
}

extension ISO_9945.Kernel.File.Chown.Error {

    @usableFromInline
    internal static func current() -> Self {
        let code = Error.Error.Code.current()
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
            return .platform(Error.Error(code: code))
        }
    }
}
