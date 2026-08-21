#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension Error_Primitives.Error {

    public typealias Number = Tagged<Error_Primitives.Error, Int32>
}

extension Error_Primitives.Error.Number {

    public static var noEntry: Self { Self(_unchecked: ENOENT) }

    public static var accessDenied: Self { Self(_unchecked: EACCES) }

    public static var notPermitted: Self { Self(_unchecked: EPERM) }

    public static var exists: Self { Self(_unchecked: EEXIST) }

    public static var isDirectory: Self { Self(_unchecked: EISDIR) }

    public static var processLimit: Self { Self(_unchecked: EMFILE) }

    public static var systemLimit: Self { Self(_unchecked: ENFILE) }

    public static var invalid: Self { Self(_unchecked: EINVAL) }

    public static var interrupted: Self { Self(_unchecked: EINTR) }

    public static var wouldBlock: Self { Self(_unchecked: EAGAIN) }

    public static var inProgress: Self { Self(_unchecked: EINPROGRESS) }

    public static var noDevice: Self { Self(_unchecked: ENODEV) }

    public static var notDirectory: Self { Self(_unchecked: ENOTDIR) }

    public static var readOnlyFilesystem: Self { Self(_unchecked: EROFS) }

    public static var noSpace: Self { Self(_unchecked: ENOSPC) }

    public static var badDescriptor: Self { Self(_unchecked: EBADF) }

    public static var ioError: Self { Self(_unchecked: EIO) }

    public static var noMemory: Self { Self(_unchecked: ENOMEM) }
}
