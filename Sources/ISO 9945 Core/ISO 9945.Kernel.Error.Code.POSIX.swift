extension Error_Primitives.Error.Code {

    public enum POSIX {}
}

extension Error_Primitives.Error.Code.POSIX {

    @inlinable
    public static var EPERM: Error_Primitives.Error.Code { .posix(1) }

    @inlinable
    public static var EACCES: Error_Primitives.Error.Code { .posix(13) }

    @inlinable
    public static var EROFS: Error_Primitives.Error.Code { .posix(30) }

    @inlinable
    public static var ENOENT: Error_Primitives.Error.Code { .posix(2) }

    @inlinable
    public static var EEXIST: Error_Primitives.Error.Code { .posix(17) }

    @inlinable
    public static var EXDEV: Error_Primitives.Error.Code { .posix(18) }

    @inlinable
    public static var ENOTDIR: Error_Primitives.Error.Code { .posix(20) }

    @inlinable
    public static var EISDIR: Error_Primitives.Error.Code { .posix(21) }

    @inlinable
    public static var EBADF: Error_Primitives.Error.Code { .posix(9) }

    @inlinable
    public static var EIO: Error_Primitives.Error.Code { .posix(5) }

    @inlinable
    public static var ENXIO: Error_Primitives.Error.Code { .posix(6) }

    @inlinable
    public static var ENODEV: Error_Primitives.Error.Code { .posix(19) }

    @inlinable
    public static var EINVAL: Error_Primitives.Error.Code { .posix(22) }

    @inlinable
    public static var ESPIPE: Error_Primitives.Error.Code { .posix(29) }

    @inlinable
    public static var EPIPE: Error_Primitives.Error.Code { .posix(32) }

    @inlinable
    public static var ENOMEM: Error_Primitives.Error.Code { .posix(12) }

    @inlinable
    public static var EFAULT: Error_Primitives.Error.Code { .posix(14) }

    @inlinable
    public static var ENFILE: Error_Primitives.Error.Code { .posix(23) }

    @inlinable
    public static var EMFILE: Error_Primitives.Error.Code { .posix(24) }

    @inlinable
    public static var ENOSPC: Error_Primitives.Error.Code { .posix(28) }

    @inlinable
    public static var EINTR: Error_Primitives.Error.Code { .posix(4) }
}

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
    extension Error_Primitives.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error_Primitives.Error.Code { .posix(35) }

        @inlinable
        public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(35) }

        @inlinable
        public static var ELOOP: Error_Primitives.Error.Code { .posix(62) }

        @inlinable
        public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(63) }

        @inlinable
        public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(66) }

        @inlinable
        public static var EDQUOT: Error_Primitives.Error.Code { .posix(69) }

        @inlinable
        public static var ECONNRESET: Error_Primitives.Error.Code { .posix(54) }

        @inlinable
        public static var ENOTSUP: Error_Primitives.Error.Code { .posix(45) }

        @inlinable
        public static var EDEADLK: Error_Primitives.Error.Code { .posix(11) }

        @inlinable
        public static var ENOLCK: Error_Primitives.Error.Code { .posix(77) }
    }
#endif

#if os(Linux) || os(Android)
    extension Error_Primitives.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error_Primitives.Error.Code { .posix(11) }

        @inlinable
        public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(11) }

        @inlinable
        public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(36) }

        @inlinable
        public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(39) }

        @inlinable
        public static var ELOOP: Error_Primitives.Error.Code { .posix(40) }

        @inlinable
        public static var EDQUOT: Error_Primitives.Error.Code { .posix(122) }

        @inlinable
        public static var ECONNRESET: Error_Primitives.Error.Code { .posix(104) }

        @inlinable
        public static var ENOTSUP: Error_Primitives.Error.Code { .posix(95) }

        @inlinable
        public static var EDEADLK: Error_Primitives.Error.Code { .posix(35) }

        @inlinable
        public static var ENOLCK: Error_Primitives.Error.Code { .posix(37) }
    }
#endif

#if os(OpenBSD)
    extension Error_Primitives.Error.Code.POSIX {

        @inlinable
        public static var EAGAIN: Error_Primitives.Error.Code { .posix(35) }

        @inlinable
        public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(35) }

        @inlinable
        public static var ELOOP: Error_Primitives.Error.Code { .posix(62) }

        @inlinable
        public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(63) }

        @inlinable
        public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(66) }

        @inlinable
        public static var EDQUOT: Error_Primitives.Error.Code { .posix(69) }

        @inlinable
        public static var ECONNRESET: Error_Primitives.Error.Code { .posix(54) }

        @inlinable
        public static var ENOTSUP: Error_Primitives.Error.Code { .posix(91) }

        @inlinable
        public static var EDEADLK: Error_Primitives.Error.Code { .posix(11) }

        @inlinable
        public static var ENOLCK: Error_Primitives.Error.Code { .posix(77) }
    }
#endif

extension Error_Primitives.Error.Code.POSIX {

    @inlinable
    public static func isELOOP(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.ELOOP
    }

    @inlinable
    public static func isENOTEMPTY(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.ENOTEMPTY
    }

    @inlinable
    public static func isENAMETOOLONG(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.ENAMETOOLONG
    }

    @inlinable
    public static func isEAGAIN(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.EAGAIN || code == Self.EWOULDBLOCK
    }

    @inlinable
    public static func isEDQUOT(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.EDQUOT
    }

    @inlinable
    public static func isECONNRESET(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.ECONNRESET
    }

    @inlinable
    public static func isENOTSUP(_ code: Error_Primitives.Error.Code) -> Bool {
        code == Self.ENOTSUP
    }
}
