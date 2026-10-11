@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Directory {
    public typealias Entry = ISO_9945.Kernel.Directory.Entry
    public typealias Error = ISO_9945.Kernel.Directory.Error

    @unsafe
    public static func open(at path: UnsafePointer<Path.Char>) throws(Error) -> Stream {
        let cPath = unsafe UnsafePointer<CChar>(path)

        guard let dir = unsafe opendir(cPath) else {
            throw Error.currentOpen()
        }
        return unsafe Stream(dir: dir)
    }

    public static func open(at path: borrowing Path.Borrowed) throws(Error) -> Stream {
        try unsafe path.withUnsafePointer { (ptr: UnsafePointer<Path.Char>) throws(Error) in
            try unsafe open(at: ptr)
        }
    }
}

extension ISO_9945.Kernel.Directory.Error {

    internal static func currentOpen() -> Self {
        let code = Error::Error.Code.captureErrno()
        switch code {
        case .ENOENT:
            return .notFound

        case .EACCES:
            return .permission

        case .ENOTDIR:
            return .notDirectory

        case .EMFILE, .ENFILE:
            return .tooManyOpenFiles

        default:
            return .platform(Error::Error(code: code))
        }
    }

    internal static func currentRead() -> Self {
        let code = Error::Error.Code.captureErrno()
        switch code {
        case .EIO:
            return .io

        default:
            return .platform(Error::Error(code: code))
        }
    }
}
