
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
    /// Looks up a user by name.
    ///
    /// - Parameter name: The user name to look up.
    /// - Returns: The user entry, or `nil` if not found.
    public static func find(name: String) -> Entry? {
        guard let pw = unsafe getpwnam(name) else { return nil }
        return unsafe entry(from: pw)
    }

    /// Looks up a user by user ID.
    ///
    /// - Parameter uid: The user ID to look up.
    /// - Returns: The user entry, or `nil` if not found.
    public static func find(uid: Kernel.User.ID) -> Entry? {
        guard let pw = unsafe getpwuid(uid.rawValue) else { return nil }
        return unsafe entry(from: pw)
    }

    private static func entry(from pw: UnsafePointer<passwd>) -> Entry {
        unsafe Entry(
            name: String(cString: pw.pointee.pw_name),
            uid: Kernel.User.ID(__unchecked: (), pw.pointee.pw_uid),
            gid: Kernel.Group.ID(__unchecked: (), pw.pointee.pw_gid),
            home: String(cString: pw.pointee.pw_dir),
            shell: String(cString: pw.pointee.pw_shell)
        )
    }
}
