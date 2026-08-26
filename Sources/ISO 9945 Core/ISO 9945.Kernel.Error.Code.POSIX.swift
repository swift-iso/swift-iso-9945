extension Error.Error.Code {

    public enum POSIX {}
}

extension Error.Error.Code.POSIX {

    @inlinable
    public static var EPERM: Error.Error.Code { .posix(1) }

    @inlinable
    public static var EACCES: Error.Error.Code { .posix(13) }

    @inlinable
    public static var EROFS: Error.Error.Code { .posix(30) }

    @inlinable
    public static var ENOENT: Error.Error.Code { .posix(2) }

    @inlinable
    public static var EEXIST: Error.Error.Code { .posix(17) }

    @inlinable
    public static var EXDEV: Error.Error.Code { .posix(18) }

    @inlinable
    public static var ENOTDIR: Error.Error.Code { .posix(20) }

    @inlinable
    public static var EISDIR: Error.Error.Code { .posix(21) }

    @inlinable
    public static var EBADF: Error.Error.Code { .posix(9) }

    @inlinable
    public static var EIO: Error.Error.Code { .posix(5) }

    @inlinable
    public static var ENXIO: Error.Error.Code { .posix(6) }

    @inlinable
    public static var ENODEV: Error.Error.Code { .posix(19) }

    @inlinable
    public static var EINVAL: Error.Error.Code { .posix(22) }

    @inlinable
    public static var ESPIPE: Error.Error.Code { .posix(29) }

    @inlinable
    public static var EPIPE: Error.Error.Code { .posix(32) }

    @inlinable
    public static var ENOMEM: Error.Error.Code { .posix(12) }

    @inlinable
    public static var EFAULT: Error.Error.Code { .posix(14) }

    @inlinable
    public static var ENFILE: Error.Error.Code { .posix(23) }

    @inlinable
    public static var EMFILE: Error.Error.Code { .posix(24) }

    @inlinable
    public static var ENOSPC: Error.Error.Code { .posix(28) }

    @inlinable
    public static var EINTR: Error.Error.Code { .posix(4) }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    extension Error.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error.Error.Code { .posix(35) }

        @inlinable
        public static var EWOULDBLOCK: Error.Error.Code { .posix(35) }

        @inlinable
        public static var ELOOP: Error.Error.Code { .posix(62) }

        @inlinable
        public static var ENAMETOOLONG: Error.Error.Code { .posix(63) }

        @inlinable
        public static var ENOTEMPTY: Error.Error.Code { .posix(66) }

        @inlinable
        public static var EDQUOT: Error.Error.Code { .posix(69) }

        @inlinable
        public static var ECONNRESET: Error.Error.Code { .posix(54) }

        @inlinable
        public static var ENOTSUP: Error.Error.Code { .posix(45) }

        @inlinable
        public static var EDEADLK: Error.Error.Code { .posix(11) }

        @inlinable
        public static var ENOLCK: Error.Error.Code { .posix(77) }
    }
#endif

#if os(Linux) || os(Android)
    extension Error.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error.Error.Code { .posix(11) }

        @inlinable
        public static var EWOULDBLOCK: Error.Error.Code { .posix(11) }

        @inlinable
        public static var ENAMETOOLONG: Error.Error.Code { .posix(36) }

        @inlinable
        public static var ENOTEMPTY: Error.Error.Code { .posix(39) }

        @inlinable
        public static var ELOOP: Error.Error.Code { .posix(40) }

        @inlinable
        public static var EDQUOT: Error.Error.Code { .posix(122) }

        @inlinable
        public static var ECONNRESET: Error.Error.Code { .posix(104) }

        @inlinable
        public static var ENOTSUP: Error.Error.Code { .posix(95) }

        @inlinable
        public static var EDEADLK: Error.Error.Code { .posix(35) }

        @inlinable
        public static var ENOLCK: Error.Error.Code { .posix(37) }
    }
#endif

#if os(OpenBSD)
    extension Error.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error.Error.Code { .posix(35) }

        @inlinable
        public static var EWOULDBLOCK: Error.Error.Code { .posix(35) }

        @inlinable
        public static var ELOOP: Error.Error.Code { .posix(62) }

        @inlinable
        public static var ENAMETOOLONG: Error.Error.Code { .posix(63) }

        @inlinable
        public static var ENOTEMPTY: Error.Error.Code { .posix(66) }

        @inlinable
        public static var EDQUOT: Error.Error.Code { .posix(69) }

        @inlinable
        public static var ECONNRESET: Error.Error.Code { .posix(54) }

        @inlinable
        public static var ENOTSUP: Error.Error.Code { .posix(91) }

        @inlinable
        public static var EDEADLK: Error.Error.Code { .posix(11) }

        @inlinable
        public static var ENOLCK: Error.Error.Code { .posix(77) }
    }
#endif

extension Error.Error.Code.POSIX {

    @inlinable
    public static func isELOOP(_ code: Error.Error.Code) -> Bool {
        code == Self.ELOOP
    }

    @inlinable
    public static func isENOTEMPTY(_ code: Error.Error.Code) -> Bool {
        code == Self.ENOTEMPTY
    }

    @inlinable
    public static func isENAMETOOLONG(_ code: Error.Error.Code) -> Bool {
        code == Self.ENAMETOOLONG
    }

    @inlinable
    public static func isEAGAIN(_ code: Error.Error.Code) -> Bool {
        code == Self.EAGAIN || code == Self.EWOULDBLOCK
    }

    @inlinable
    public static func isEDQUOT(_ code: Error.Error.Code) -> Bool {
        code == Self.EDQUOT
    }

    @inlinable
    public static func isECONNRESET(_ code: Error.Error.Code) -> Bool {
        code == Self.ECONNRESET
    }

    @inlinable
    public static func isENOTSUP(_ code: Error.Error.Code) -> Bool {
        code == Self.ENOTSUP
    }
}
