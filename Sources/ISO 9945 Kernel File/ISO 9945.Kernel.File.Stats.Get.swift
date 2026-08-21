@_spi(Syscall) import ISO_9945_Core

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.File.Stats {

    internal static func get(
        fd: Int32
    ) throws(ISO_9945.Kernel.File.Stats.Error) -> ISO_9945.Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (Darwin.fstat(fd, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard unsafe (Musl.fstat(fd, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard unsafe (Glibc.fstat(fd, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #endif
        return ISO_9945.Kernel.File.Stats(from: sb)
    }
}

extension ISO_9945.Kernel.File.Stats {

    public static func get(
        descriptor: borrowing ISO_9945.Kernel.Descriptor
    ) throws(ISO_9945.Kernel.File.Stats.Error) -> ISO_9945.Kernel.File.Stats {
        try get(fd: descriptor._rawValue)
    }

    public static func get(
        path: borrowing Path.Borrowed
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe get(unsafePath: UnsafePointer<CChar>(cString))
        }
    }

    @unsafe
    public static func get(
        at path: UnsafePointer<Path.Char>
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        try unsafe get(unsafePath: UnsafePointer<CChar>(path))
    }

    internal static func get(
        unsafePath path: UnsafePointer<CChar>
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (stat(path, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard stat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard stat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #endif
        return ISO_9945.Kernel.File.Stats(from: sb)
    }

    public static func lget(
        path: borrowing Path.Borrowed
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        try unsafe path.withUnsafePointer { cString throws(Error) in
            try unsafe lget(unsafePath: UnsafePointer<CChar>(cString))
        }
    }

    @unsafe
    public static func lget(
        at path: UnsafePointer<Path.Char>
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        try unsafe lget(unsafePath: UnsafePointer<CChar>(path))
    }

    internal static func lget(
        unsafePath path: UnsafePointer<CChar>
    ) throws(Error) -> ISO_9945.Kernel.File.Stats {
        #if canImport(Darwin)
            var sb = Darwin.stat()
            guard unsafe (Darwin.lstat(path, &sb) == 0) else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Musl)
            var sb = Musl.stat()
            guard Musl.lstat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #elseif canImport(Glibc)
            var sb = Glibc.stat()
            guard Glibc.lstat(path, &sb) == 0 else {
                throw Error(posixErrno: errno)
            }
        #endif
        return ISO_9945.Kernel.File.Stats(from: sb)
    }
}

extension ISO_9945.Kernel.File.Stats.Error {
    internal init(posixErrno code: Int32) {
        let errorCode = Error_Primitives.Error.Code.posix(code)
        if let e = ISO_9945.Kernel.Descriptor.Validity.Error(code: errorCode) {
            self = .handle(e)
            return
        }
        self = .platform(Error_Primitives.Error(code: errorCode))
    }
}

#if canImport(Darwin)
    extension ISO_9945.Kernel.File.Stats {

        internal init(from sb: Darwin.stat) {
            let atime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_atimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_atimespec.tv_nsec)
            )
            let mtime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_mtimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_mtimespec.tv_nsec)
            )
            let ctime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_ctimespec.tv_sec),
                nanosecondFraction: Int32(sb.st_ctimespec.tv_nsec)
            )

            self.init(
                size: ISO_9945.Kernel.File.Size(Int64(sb.st_size)),
                type: Kind(mode: sb.st_mode),
                permissions: ISO_9945.Kernel.File.Permissions(
                    rawValue: UInt16(sb.st_mode & 0o7777)
                ),
                uid: ISO_9945.Kernel.User.ID(_unchecked: UInt32(sb.st_uid)),
                gid: ISO_9945.Kernel.Group.ID(_unchecked: UInt32(sb.st_gid)),
                inode: ISO_9945.Kernel.Inode(UInt64(sb.st_ino)),
                device: ISO_9945.Kernel.Device(UInt64(sb.st_dev)),
                linkCount: ISO_9945.Kernel.Link.Count(_unchecked: Cardinal(UInt(sb.st_nlink))),
                accessTime: atime,
                modificationTime: mtime,
                changeTime: ctime
            )
        }
    }
#elseif canImport(Glibc)
    extension ISO_9945.Kernel.File.Stats {

        internal init(from sb: Glibc.stat) {
            let atime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_atim.tv_sec),
                nanosecondFraction: Int32(sb.st_atim.tv_nsec)
            )
            let mtime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_mtim.tv_sec),
                nanosecondFraction: Int32(sb.st_mtim.tv_nsec)
            )
            let ctime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_ctim.tv_sec),
                nanosecondFraction: Int32(sb.st_ctim.tv_nsec)
            )

            self.init(
                size: ISO_9945.Kernel.File.Size(Int64(sb.st_size)),
                type: Kind(mode: sb.st_mode),
                permissions: ISO_9945.Kernel.File.Permissions(
                    rawValue: UInt16(sb.st_mode & 0o7777)
                ),
                uid: ISO_9945.Kernel.User.ID(_unchecked: UInt32(sb.st_uid)),
                gid: ISO_9945.Kernel.Group.ID(_unchecked: UInt32(sb.st_gid)),
                inode: ISO_9945.Kernel.Inode(UInt64(sb.st_ino)),
                device: ISO_9945.Kernel.Device(UInt64(sb.st_dev)),
                linkCount: ISO_9945.Kernel.Link.Count(_unchecked: Cardinal(UInt(sb.st_nlink))),
                accessTime: atime,
                modificationTime: mtime,
                changeTime: ctime
            )
        }
    }
#elseif canImport(Musl)
    extension ISO_9945.Kernel.File.Stats {

        internal init(from sb: Musl.stat) {
            let atime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_atim.tv_sec),
                nanosecondFraction: Int32(sb.st_atim.tv_nsec)
            )
            let mtime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_mtim.tv_sec),
                nanosecondFraction: Int32(sb.st_mtim.tv_nsec)
            )
            let ctime = ISO_9945.Kernel.Time(
                _unchecked: (),
                secondsSinceUnixEpoch: Int64(sb.st_ctim.tv_sec),
                nanosecondFraction: Int32(sb.st_ctim.tv_nsec)
            )

            self.init(
                size: ISO_9945.Kernel.File.Size(Int64(sb.st_size)),
                type: Kind(mode: sb.st_mode),
                permissions: ISO_9945.Kernel.File.Permissions(
                    rawValue: UInt16(sb.st_mode & 0o7777)
                ),
                uid: ISO_9945.Kernel.User.ID(_unchecked: UInt32(sb.st_uid)),
                gid: ISO_9945.Kernel.Group.ID(_unchecked: UInt32(sb.st_gid)),
                inode: ISO_9945.Kernel.Inode(UInt64(sb.st_ino)),
                device: ISO_9945.Kernel.Device(UInt64(sb.st_dev)),
                linkCount: ISO_9945.Kernel.Link.Count(_unchecked: Cardinal(UInt(sb.st_nlink))),
                accessTime: atime,
                modificationTime: mtime,
                changeTime: ctime
            )
        }
    }
#endif

extension ISO_9945.Kernel.File.Stats.Kind {

    internal init(mode: mode_t) {
        let fileType = mode & S_IFMT
        switch fileType {
        case S_IFREG:
            self = .regular

        case S_IFDIR:
            self = .directory

        case S_IFLNK:
            self = .link(.symbolic)

        case S_IFBLK:
            self = .device(.block)

        case S_IFCHR:
            self = .device(.character)

        case S_IFIFO:
            self = .fifo

        case S_IFSOCK:
            self = .socket

        default:
            self = .unknown
        }
    }
}
