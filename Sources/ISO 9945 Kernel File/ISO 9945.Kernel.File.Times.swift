@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Times {

    public static func set(
        access accessTime: ISO_9945.Kernel.Time,
        modification modificationTime: ISO_9945.Kernel.Time,
        at path: borrowing Path.Borrowed,
        followSymlinks: Bool = true
    ) throws(Error) {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe _set(
                access: accessTime,
                modification: modificationTime,
                path: cString,
                followSymlinks: followSymlinks
            )
        }
    }

    @usableFromInline
    internal static func _set(
        access accessTime: ISO_9945.Kernel.Time,
        modification modificationTime: ISO_9945.Kernel.Time,
        path: UnsafePointer<Path.Char>,
        followSymlinks: Bool = true
    ) throws(Error) {
        guard let accessSeconds = time_t(exactly: accessTime.secondsSinceUnixEpoch),
            let modificationSeconds = time_t(exactly: modificationTime.secondsSinceUnixEpoch)
        else {
            throw Error.unrepresentable
        }

        let cPath = unsafe UnsafePointer<CChar>(path)
        var times = [timespec](repeating: timespec(), count: 2)

        times[0].tv_sec = accessSeconds
        times[0].tv_nsec = Int(accessTime.nanosecondFraction)

        times[1].tv_sec = modificationSeconds
        times[1].tv_nsec = Int(modificationTime.nanosecondFraction)

        let flags: Int32 = followSymlinks ? 0 : AT_SYMLINK_NOFOLLOW

        #if canImport(Darwin)
            let result = unsafe Darwin.utimensat(AT_FDCWD, cPath, &times, flags)
        #elseif canImport(Musl)
            let result = Musl.utimensat(AT_FDCWD, cPath, &times, flags)
        #elseif canImport(Glibc)
            let result = Glibc.utimensat(AT_FDCWD, cPath, &times, flags)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Times {

    @_spi(Syscall)
    public static func set(
        access accessTime: ISO_9945.Kernel.Time,
        modification modificationTime: ISO_9945.Kernel.Time,
        fd: Int32
    ) throws(Error) {
        guard let accessSeconds = time_t(exactly: accessTime.secondsSinceUnixEpoch),
            let modificationSeconds = time_t(exactly: modificationTime.secondsSinceUnixEpoch)
        else {
            throw Error.unrepresentable
        }

        var times = [timespec](repeating: timespec(), count: 2)

        times[0].tv_sec = accessSeconds
        times[0].tv_nsec = Int(accessTime.nanosecondFraction)

        times[1].tv_sec = modificationSeconds
        times[1].tv_nsec = Int(modificationTime.nanosecondFraction)

        #if canImport(Darwin)
            let result = unsafe Darwin.futimens(fd, &times)
        #elseif canImport(Musl)
            let result = unsafe Musl.futimens(fd, &times)
        #elseif canImport(Glibc)
            let result = unsafe Glibc.futimens(fd, &times)
        #endif

        guard result == 0 else {
            throw Error.current()
        }
    }
}

extension ISO_9945.Kernel.File.Times {

    public static func set(
        access accessTime: ISO_9945.Kernel.Time,
        modification modificationTime: ISO_9945.Kernel.Time,
        on descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(Error) {
        try set(
            access: accessTime,
            modification: modificationTime,
            fd: descriptor._rawValue
        )
    }
}

extension ISO_9945.Kernel.File.Times.Error {

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
