@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Effective User ID

extension ISO_9945.Kernel.User {
    /// Effective user ID operations namespace.
    public enum Effective {}
}

extension ISO_9945.Kernel.User.Effective {
    /// Gets the effective user ID of the calling process.
    public static func id() -> Kernel.User.ID {
        Kernel.User.ID(__unchecked: (), geteuid())
    }

    /// Sets the effective user ID of the calling process.
    ///
    /// - Throws: `Kernel.Error` on failure (EPERM if not privileged).
    public static func set(
        _ uid: Kernel.User.ID
    ) throws(Kernel.Error) {
        guard seteuid(uid.rawValue) == 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "seteuid")
        }
    }
}
