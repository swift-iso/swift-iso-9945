extension Error::Error.Code {

    @inlinable
    public var isNotFound: Bool {
        self == .ENOENT
    }

    @inlinable
    public var isPermissionDenied: Bool {
        self == .EACCES || self == .EPERM
    }

    @inlinable
    public var isAccessDenied: Bool {
        isPermissionDenied
    }

    @inlinable
    public var isReadOnly: Bool {
        self == .EROFS
    }

    @inlinable
    public var isNoSpace: Bool {
        self == .ENOSPC
    }

    @inlinable
    public var isNotDirectory: Bool {
        self == .ENOTDIR
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
