// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-iso-9945 open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-iso-9945 project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

extension Error_Primitives.Error.Code {
    /// POSIX errno constants.
    ///
    /// Named constants for common POSIX error codes. Use these instead of
    /// magic numbers when matching error codes in switch statements.
    ///
    /// ## Example
    ///
    /// ```swift
    /// switch code {
    /// case .POSIX.ENOENT:
    ///     // Handle "no such file or directory"
    /// case .EACCES:
    ///     // Handle "permission denied"
    /// default:
    ///     break
    /// }
    /// ```
    ///
    /// ## Platform Differences
    ///
    /// Some errno values differ between platforms (Darwin vs Linux).
    /// Where values differ, both platform-specific constants are provided:
    /// - `ELOOP_darwin`, `ELOOP_linux`
    /// - `ENOTEMPTY_darwin`, `ENOTEMPTY_linux`
    /// - `ENAMETOOLONG_darwin`, `ENAMETOOLONG_linux`
    public enum POSIX {}
}

// MARK: - Standard POSIX Errors (Portable)

extension Error_Primitives.Error.Code.POSIX {
    // MARK: Permission and Access Errors

    /// Operation not permitted (errno 1).
    ///
    /// Indicates an operation that requires special privileges
    /// (e.g., changing file ownership to another user).
    @inlinable
    public static var EPERM: Error_Primitives.Error.Code { .posix(1) }

    /// Permission denied (errno 13).
    ///
    /// File/directory access control denied the operation.
    @inlinable
    public static var EACCES: Error_Primitives.Error.Code { .posix(13) }

    /// Read-only file system (errno 30).
    @inlinable
    public static var EROFS: Error_Primitives.Error.Code { .posix(30) }

    // MARK: Path Resolution Errors

    /// No such file or directory (errno 2).
    @inlinable
    public static var ENOENT: Error_Primitives.Error.Code { .posix(2) }

    /// File exists (errno 17).
    @inlinable
    public static var EEXIST: Error_Primitives.Error.Code { .posix(17) }

    /// Cross-device link (errno 18).
    @inlinable
    public static var EXDEV: Error_Primitives.Error.Code { .posix(18) }

    /// Not a directory (errno 20).
    @inlinable
    public static var ENOTDIR: Error_Primitives.Error.Code { .posix(20) }

    /// Is a directory (errno 21).
    @inlinable
    public static var EISDIR: Error_Primitives.Error.Code { .posix(21) }

    // MARK: Descriptor Errors

    /// Bad file descriptor (errno 9).
    @inlinable
    public static var EBADF: Error_Primitives.Error.Code { .posix(9) }

    // MARK: I/O Errors

    /// I/O error (errno 5).
    @inlinable
    public static var EIO: Error_Primitives.Error.Code { .posix(5) }

    /// Device not configured (errno 6).
    @inlinable
    public static var ENXIO: Error_Primitives.Error.Code { .posix(6) }

    /// No such device (errno 19).
    @inlinable
    public static var ENODEV: Error_Primitives.Error.Code { .posix(19) }

    /// Invalid argument (errno 22).
    @inlinable
    public static var EINVAL: Error_Primitives.Error.Code { .posix(22) }

    /// Illegal seek (errno 29).
    @inlinable
    public static var ESPIPE: Error_Primitives.Error.Code { .posix(29) }

    /// Broken pipe (errno 32).
    @inlinable
    public static var EPIPE: Error_Primitives.Error.Code { .posix(32) }

    // MARK: Resource Errors

    /// Cannot allocate memory (errno 12).
    @inlinable
    public static var ENOMEM: Error_Primitives.Error.Code { .posix(12) }

    /// Bad address (errno 14).
    @inlinable
    public static var EFAULT: Error_Primitives.Error.Code { .posix(14) }

    /// Too many open files in system (errno 23).
    @inlinable
    public static var ENFILE: Error_Primitives.Error.Code { .posix(23) }

    /// Too many open files (errno 24).
    @inlinable
    public static var EMFILE: Error_Primitives.Error.Code { .posix(24) }

    /// No space left on device (errno 28).
    @inlinable
    public static var ENOSPC: Error_Primitives.Error.Code { .posix(28) }

    // MARK: Interrupt and Blocking

    /// Interrupted system call (errno 4).
    @inlinable
    public static var EINTR: Error_Primitives.Error.Code { .posix(4) }
}

// MARK: - Darwin-Specific Values

#if os(macOS) || os(iOS) || os(tvOS) || os(watchOS) || os(visionOS)
extension Error_Primitives.Error.Code.POSIX {
    /// Resource temporarily unavailable (Darwin errno 35).
    ///
    /// On Darwin, EAGAIN and EWOULDBLOCK have the same value (35).
    @inlinable
    public static var EAGAIN: Error_Primitives.Error.Code { .posix(35) }

    /// Operation would block (Darwin errno 35).
    ///
    /// On Darwin, EAGAIN and EWOULDBLOCK have the same value (35).
    @inlinable
    public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(35) }

    /// Too many levels of symbolic links (Darwin errno 62).
    @inlinable
    public static var ELOOP: Error_Primitives.Error.Code { .posix(62) }

    /// File name too long (Darwin errno 63).
    @inlinable
    public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(63) }

    /// Directory not empty (Darwin errno 66).
    @inlinable
    public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(66) }

    /// Disc quota exceeded (Darwin errno 69).
    @inlinable
    public static var EDQUOT: Error_Primitives.Error.Code { .posix(69) }

    /// Connection reset by peer (Darwin errno 54).
    @inlinable
    public static var ECONNRESET: Error_Primitives.Error.Code { .posix(54) }

    /// Operation not supported (Darwin errno 45).
    @inlinable
    public static var ENOTSUP: Error_Primitives.Error.Code { .posix(45) }

    /// Deadlock detected (Darwin errno 11).
    @inlinable
    public static var EDEADLK: Error_Primitives.Error.Code { .posix(11) }

    /// No locks available (Darwin errno 77).
    @inlinable
    public static var ENOLCK: Error_Primitives.Error.Code { .posix(77) }
}
#endif

// MARK: - Linux-Specific Values

#if os(Linux) || os(Android)
extension Error_Primitives.Error.Code.POSIX {
    /// Resource temporarily unavailable (Linux errno 11).
    ///
    /// On Linux, EAGAIN and EWOULDBLOCK have the same value (11).
    @inlinable
    public static var EAGAIN: Error_Primitives.Error.Code { .posix(11) }

    /// Operation would block (Linux errno 11).
    ///
    /// On Linux, EAGAIN and EWOULDBLOCK have the same value (11).
    @inlinable
    public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(11) }

    /// File name too long (Linux errno 36).
    @inlinable
    public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(36) }

    /// Directory not empty (Linux errno 39).
    @inlinable
    public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(39) }

    /// Too many levels of symbolic links (Linux errno 40).
    @inlinable
    public static var ELOOP: Error_Primitives.Error.Code { .posix(40) }

    /// Disc quota exceeded (Linux errno 122).
    @inlinable
    public static var EDQUOT: Error_Primitives.Error.Code { .posix(122) }

    /// Connection reset by peer (Linux errno 104).
    @inlinable
    public static var ECONNRESET: Error_Primitives.Error.Code { .posix(104) }

    /// Operation not supported (Linux errno 95).
    @inlinable
    public static var ENOTSUP: Error_Primitives.Error.Code { .posix(95) }

    /// Deadlock detected (Linux errno 35).
    @inlinable
    public static var EDEADLK: Error_Primitives.Error.Code { .posix(35) }

    /// No locks available (Linux errno 37).
    @inlinable
    public static var ENOLCK: Error_Primitives.Error.Code { .posix(37) }
}
#endif

// MARK: - OpenBSD-Specific Values

#if os(OpenBSD)
extension Error_Primitives.Error.Code.POSIX {
    /// Resource temporarily unavailable (OpenBSD errno 35).
    @inlinable
    public static var EAGAIN: Error_Primitives.Error.Code { .posix(35) }

    /// Operation would block (OpenBSD errno 35).
    @inlinable
    public static var EWOULDBLOCK: Error_Primitives.Error.Code { .posix(35) }

    /// Too many levels of symbolic links (OpenBSD errno 62).
    @inlinable
    public static var ELOOP: Error_Primitives.Error.Code { .posix(62) }

    /// File name too long (OpenBSD errno 63).
    @inlinable
    public static var ENAMETOOLONG: Error_Primitives.Error.Code { .posix(63) }

    /// Directory not empty (OpenBSD errno 66).
    @inlinable
    public static var ENOTEMPTY: Error_Primitives.Error.Code { .posix(66) }

    /// Disc quota exceeded (OpenBSD errno 69).
    @inlinable
    public static var EDQUOT: Error_Primitives.Error.Code { .posix(69) }

    /// Connection reset by peer (OpenBSD errno 54).
    @inlinable
    public static var ECONNRESET: Error_Primitives.Error.Code { .posix(54) }

    /// Operation not supported (OpenBSD errno 91).
    @inlinable
    public static var ENOTSUP: Error_Primitives.Error.Code { .posix(91) }

    /// Deadlock detected (OpenBSD errno 11).
    @inlinable
    public static var EDEADLK: Error_Primitives.Error.Code { .posix(11) }

    /// No locks available (OpenBSD errno 77).
    @inlinable
    public static var ENOLCK: Error_Primitives.Error.Code { .posix(77) }
}
#endif

// MARK: - Cross-Platform Matching Helpers

extension Error_Primitives.Error.Code.POSIX {
    /// Returns `true` if the code represents ELOOP on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isELOOP(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(40), .posix(62):  // Linux 40, Darwin/OpenBSD 62
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents ENOTEMPTY on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isENOTEMPTY(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(39), .posix(66):  // Linux 39, Darwin/OpenBSD 66
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents ENAMETOOLONG on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isENAMETOOLONG(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(36), .posix(63):  // Linux 36, Darwin/OpenBSD 63
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents EAGAIN/EWOULDBLOCK on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isEAGAIN(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(11), .posix(35):  // Linux 11, Darwin/OpenBSD 35
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents EDQUOT on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isEDQUOT(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(69), .posix(122):  // Darwin/OpenBSD 69, Linux 122
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents ECONNRESET on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isECONNRESET(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(54), .posix(104):  // Darwin/OpenBSD 54, Linux 104
            return true
        default:
            return false
        }
    }

    /// Returns `true` if the code represents ENOTSUP on any platform.
    ///
    /// Use this for cross-platform matching when the value differs by platform.
    @inlinable
    public static func isENOTSUP(_ code: Error_Primitives.Error.Code) -> Bool {
        switch code {
        case .posix(45), .posix(91), .posix(95):  // Darwin 45, OpenBSD 91, Linux 95
            return true
        default:
            return false
        }
    }
}
