@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Move {

    @unsafe
    public static func move(
        from oldPath: UnsafePointer<Path.Char>,
        to newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafePointer<CChar>(oldPath)
        let cNewPath = unsafe UnsafePointer<CChar>(newPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.rename(cOldPath, cNewPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.rename(cOldPath, cNewPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.rename(cOldPath, cNewPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }

    public static func move(
        from oldPath: borrowing Path.Borrowed,
        to newPath: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe oldPath.withUnsafePointer { (oldPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe newPath.withUnsafePointer {
                (newPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe move(from: oldPtr, to: newPtr)
            }
        }
    }
}

extension ISO_9945.Kernel.File.Move {

    @_spi(Syscall)
    public static func move(
        from oldFd: Int32,
        oldPath: UnsafePointer<Path.Char>,
        to newFd: Int32,
        newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cOldPath = unsafe UnsafePointer<CChar>(oldPath)
        let cNewPath = unsafe UnsafePointer<CChar>(newPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.renameat(oldFd, cOldPath, newFd, cNewPath)
        #elseif canImport(Musl)
            let result = unsafe Musl.renameat(oldFd, cOldPath, newFd, cNewPath)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.renameat(oldFd, cOldPath, newFd, cNewPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Move {

    public static func move(
        from oldDescriptor: borrowing ISO_9945.Kernel.Descriptor,
        oldPath: UnsafePointer<Path.Char>,
        to newDescriptor: borrowing ISO_9945.Kernel.Descriptor,
        newPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        try unsafe move(
            from: oldDescriptor._rawValue,
            oldPath: oldPath,
            to: newDescriptor._rawValue,
            newPath: newPath
        )
    }
}

extension ISO_9945.Kernel.File.Move {
    public typealias Error = ISO_9945.Kernel.File.Move.Error
}

extension ISO_9945.Kernel.File.Move.Error {

    internal static func current() -> Self {
        Self(code: Error::Error.Code.captureErrno())
    }

    public init(code: Error::Error.Code) {
        self =
            switch code {
            case .ENOENT:
                .notFound

            case .EACCES, .EPERM:
                .permission

            case .EXDEV:
                .crossDevice

            case .EEXIST:
                .exists

            case .ENOTSUP:
                .notSupported

            case .ENOTEMPTY:
                .notEmpty

            case .ENOTDIR:
                .notDirectory

            case .EINVAL:
                .invalidArgument

            case .EISDIR:
                .isDirectory

            case .EROFS:
                .readOnly

            case .ELOOP:
                .loop

            case .ENAMETOOLONG:
                .nameTooLong

            case .ENOSPC:
                .noSpace

            default:
                .platform(Error::Error(code: code))
            }
    }
}
