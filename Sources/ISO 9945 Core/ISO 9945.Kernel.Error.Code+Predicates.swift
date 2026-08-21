extension Error_Primitives.Error.Code {

    @inlinable
    public var isNotFound: Bool {
        self == .POSIX.ENOENT
    }

    @inlinable
    public var isPermissionDenied: Bool {
        self == .POSIX.EACCES || self == .POSIX.EPERM
    }

    @inlinable
    public var isAccessDenied: Bool {
        isPermissionDenied
    }

    @inlinable
    public var isReadOnly: Bool {
        self == .POSIX.EROFS
    }

    @inlinable
    public var isNoSpace: Bool {
        self == .POSIX.ENOSPC
    }

    @inlinable
    public var isNotDirectory: Bool {
        self == .POSIX.ENOTDIR
    }

    @inlinable
    public var isInvalidPath: Bool {
        false
    }

    @inlinable
    public var isNetworkNotFound: Bool {
        false
    }
}
