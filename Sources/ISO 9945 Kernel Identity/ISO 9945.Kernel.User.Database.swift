#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.User {
    /// Password database (passwd) operations namespace.
    public enum Database {}
}

// MARK: - Lookup

extension ISO_9945.Kernel.User.Database {
    /// The largest buffer this type will grow to before giving up on
    /// `ERANGE` and reporting a lookup failure instead of looping forever
    /// against a database entry (or a broken NSS module) that never fits.
    private static let maximumBufferSize = 1 << 20  // 1 MiB

    /// Looks up a user by name.
    ///
    /// Uses the reentrant `getpwnam_r(3)`, which reads into a caller-owned
    /// buffer rather than the shared static storage `getpwnam(3)` returns —
    /// safe under concurrent lookups on other threads.
    ///
    /// - Parameter name: The user name to look up.
    /// - Returns: The user entry, or `nil` if no such user exists.
    /// - Throws: `Error.lookup` if the lookup itself fails (distinct from
    ///   the name simply having no entry).
    public static func find(name: String) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, pwd, result in
            unsafe name.withCString { cName in
                unsafe getpwnam_r(cName, pwd, buffer.baseAddress, numericCast(buffer.count), result)
            }
        }
    }

    /// Looks up a user by user ID.
    ///
    /// Uses the reentrant `getpwuid_r(3)`; see `find(name:)`.
    ///
    /// - Parameter uid: The user ID to look up.
    /// - Returns: The user entry, or `nil` if no such user exists.
    /// - Throws: `Error.lookup` if the lookup itself fails (distinct from
    ///   the ID simply having no entry).
    public static func find(uid: ISO_9945.Kernel.User.ID) throws(Error) -> Entry? {
        try unsafe withReentrantLookup { buffer, pwd, result in
            unsafe getpwuid_r(uid.underlying, pwd, buffer.baseAddress, numericCast(buffer.count), result)
        }
    }

    /// Runs a `getpwnam_r`/`getpwuid_r`-shaped lookup, growing the scratch
    /// buffer on `ERANGE` up to `maximumBufferSize`.
    ///
    /// - Parameter lookup: Invokes the underlying `_r` call with the
    ///   current buffer, the `passwd` storage to fill, and the out
    ///   parameter that is set non-nil iff an entry was found. Returns the
    ///   `_r` call's raw result code (`0` on success, whether or not an
    ///   entry was found; nonzero is a genuine failure).
    private static func withReentrantLookup(
        _ lookup: (
            UnsafeMutableBufferPointer<CChar>,
            UnsafeMutablePointer<passwd>,
            UnsafeMutablePointer<UnsafeMutablePointer<passwd>?>
        ) -> Int32
    ) throws(Error) -> Entry? {
        var bufferSize = initialBufferSize()
        while true {
            var pwd = passwd()
            var resultPtr: UnsafeMutablePointer<passwd>?
            var buffer = [CChar](repeating: 0, count: bufferSize)

            let rc = unsafe buffer.withUnsafeMutableBufferPointer { bufferPtr in
                unsafe withUnsafeMutablePointer(to: &pwd) { pwdPtr in
                    unsafe withUnsafeMutablePointer(to: &resultPtr) { resultPtrPtr in
                        unsafe lookup(bufferPtr, pwdPtr, resultPtrPtr)
                    }
                }
            }

            if rc == 0 {
                guard let resultPtr = unsafe resultPtr else { return nil }
                return unsafe entry(from: resultPtr)
            }

            if rc == ERANGE, bufferSize < maximumBufferSize {
                bufferSize *= 2
                continue
            }

            throw .lookup(.posix(rc))
        }
    }

    private static func initialBufferSize() -> Int {
        let suggested = unsafe sysconf(Int32(_SC_GETPW_R_SIZE_MAX))
        return suggested > 0 ? Int(suggested) : 1024
    }

    private static func entry(from pw: UnsafePointer<passwd>) -> Entry {
        unsafe Entry(
            name: String(cString: pw.pointee.pw_name),
            uid: ISO_9945.Kernel.User.ID(_unchecked: pw.pointee.pw_uid),
            gid: ISO_9945.Kernel.Group.ID(_unchecked: pw.pointee.pw_gid),
            home: String(cString: pw.pointee.pw_dir),
            shell: String(cString: pw.pointee.pw_shell)
        )
    }
}
