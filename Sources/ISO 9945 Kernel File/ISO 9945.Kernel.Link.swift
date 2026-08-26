@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Link {

    public static func create(
        at linkPath: borrowing Path.Borrowed,
        to existingPath: borrowing Path.Borrowed
    ) throws(Error) {
        try unsafe linkPath.withUnsafePointer { (linkPtr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe existingPath.withUnsafePointer {
                (existingPtr: UnsafePointer<Path.Char>) throws(Error) in
                try unsafe _create(at: linkPtr, to: existingPtr)
            }
        }
    }

    @usableFromInline
    internal static func _create(
        at linkPath: UnsafePointer<Path.Char>,
        to existingPath: UnsafePointer<Path.Char>
    ) throws(Error) {
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)
        let cExistingPath = unsafe UnsafePointer<CChar>(existingPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.link(cExistingPath, cLinkPath)
        #elseif canImport(Musl)
            let result = Musl.link(cExistingPath, cLinkPath)
        #elseif canImport(Glibc)
            let result = Glibc.link(cExistingPath, cLinkPath)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.Link {

    @_spi(Syscall)
    public static func create(
        fromFd existingFd: Int32,
        existingPath: UnsafePointer<Path.Char>,
        atFd linkFd: Int32,
        linkPath: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        let cExistingPath = unsafe UnsafePointer<CChar>(existingPath)
        let cLinkPath = unsafe UnsafePointer<CChar>(linkPath)

        #if canImport(Darwin)
            let result = unsafe Darwin.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #elseif canImport(Musl)
            let result = unsafe Musl.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.linkat(existingFd, cExistingPath, linkFd, cLinkPath, flags)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.Link {

    @usableFromInline
    internal static func _create(
        from existingDescriptor: borrowing ISO_9945.Kernel.Descriptor,
        existingPath: UnsafePointer<Path.Char>,
        at linkDescriptor: borrowing ISO_9945.Kernel.Descriptor,
        linkPath: UnsafePointer<Path.Char>,
        flags: Int32 = 0
    ) throws(Error) {
        try unsafe create(
            fromFd: existingDescriptor._rawValue,
            existingPath: existingPath,
            atFd: linkDescriptor._rawValue,
            linkPath: linkPath,
            flags: flags
        )
    }
}

extension ISO_9945.Kernel.Link {
    public typealias Error = ISO_9945.Kernel.Link.Error
}

extension ISO_9945.Kernel.Link.Error {

    internal static func current() -> Self {
        let code = Error.Error.Code.current()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES, .EPERM:
            return .permission

        case .EEXIST:
            return .exists

        case .EXDEV:
            return .crossDevice

        case .EISDIR:
            return .isDirectory

        case .ENOTDIR:
            return .notDirectory

        case .EROFS:
            return .readOnly

        case .EMLINK:
            return .tooManyLinks

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
