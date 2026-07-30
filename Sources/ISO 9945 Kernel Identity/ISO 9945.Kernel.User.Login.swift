#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Login Name

extension ISO_9945.Kernel.User {
    /// Login name operations namespace.
    public enum Login {}
}

extension ISO_9945.Kernel.User.Login {
    /// Errors from resolving the calling process's login name.
    public enum Error: Swift.Error, Sendable, Equatable {
        case lookup(Error_Primitives.Error.Code)
    }
}

extension ISO_9945.Kernel.User.Login.Error: CustomStringConvertible {
    public var description: Swift.String {
        switch self {
        case .lookup(let code):
            return "login name lookup failed: \(code)"
        }
    }
}

extension ISO_9945.Kernel.User.Login {
    /// The largest buffer this type will grow to before giving up on
    /// `ERANGE` and reporting a lookup failure.
    private static let maximumBufferSize = 1 << 16  // 64 KiB

    /// Gets the login name of the user associated with the calling process.
    ///
    /// Uses the reentrant `getlogin_r(3)`, which reads into a caller-owned
    /// buffer rather than the shared static storage `getlogin(3)` returns —
    /// safe under concurrent calls on other threads.
    ///
    /// - Returns: The login name, or `nil` if the process has no
    ///   controlling terminal to determine one from (`ENXIO`).
    /// - Throws: `Error.lookup` if the lookup fails for any other reason
    ///   (e.g. `EMFILE`, `ENFILE`, `EIO`, or an oversized name that
    ///   exceeded the growth cap) — distinct from there simply being no
    ///   login name to report.
    public static func name() throws(Error) -> String? {
        var bufferSize = initialBufferSize()
        while true {
            var buffer = [CChar](repeating: 0, count: bufferSize)
            let rc = unsafe buffer.withUnsafeMutableBufferPointer { bufferPtr in
                unsafe getlogin_r(bufferPtr.baseAddress!, numericCast(bufferPtr.count))
            }

            if rc == 0 {
                return unsafe buffer.withUnsafeBufferPointer { bufferPtr in
                    unsafe String(cString: bufferPtr.baseAddress!)
                }
            }

            if rc == ERANGE, bufferSize < maximumBufferSize {
                bufferSize *= 2
                continue
            }

            if rc == ENXIO {
                return nil
            }

            throw .lookup(.posix(rc))
        }
    }

    /// Starting buffer size. POSIX guarantees `LOGIN_NAME_MAX` is at least
    /// 9; this comfortably covers every real platform's login name limit
    /// (Linux's is 256) without depending on the `<limits.h>` macro being
    /// importable as a usable constant on every libc.
    private static func initialBufferSize() -> Int {
        256
    }
}
