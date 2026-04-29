@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Real User ID

extension ISO_9945.Kernel.User {
    /// Real user ID operations namespace.
    public enum Real {}
}

extension ISO_9945.Kernel.User.Real {
    /// Gets the real user ID of the calling process.
    public static func id() -> Kernel.User.ID {
        Kernel.User.ID(__unchecked: (), getuid())
    }

    /// Sets the real user ID of the calling process.
    ///
    /// - Throws: `Error_Primitives.Error` on failure (EPERM if not privileged).
    public static func set(
        _ uid: Kernel.User.ID
    ) throws(Error_Primitives.Error) {
        guard setuid(uid.rawValue) == 0 else {
            throw Error_Primitives.Error.current(operation: "setuid")
        }
    }
}
