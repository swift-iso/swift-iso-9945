
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
    /// Gets the login name of the user associated with the calling process.
    ///
    /// - Returns: The login name, or `nil` if it cannot be determined.
    public static func name() -> String? {
        guard let cStr = unsafe getlogin() else { return nil }
        return unsafe String(cString: cStr)
    }
}
