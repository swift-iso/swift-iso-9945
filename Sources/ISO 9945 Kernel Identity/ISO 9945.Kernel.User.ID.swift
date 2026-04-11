@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - User ID Query Operations

extension ISO_9945.Kernel.User {
    /// Gets the real user ID of the calling process.
    public static func realID() -> Kernel.User.ID {
        Kernel.User.ID(__unchecked: (),getuid())
    }

    /// Gets the effective user ID of the calling process.
    public static func effectiveID() -> Kernel.User.ID {
        Kernel.User.ID(__unchecked: (),geteuid())
    }

    /// Sets the real user ID of the calling process.
    ///
    /// - Throws: `Kernel.Error` on failure (EPERM if not privileged).
    public static func setRealID(
        _ uid: Kernel.User.ID
    ) throws(Kernel.Error) {
        guard setuid(uid.rawValue) == 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "setuid")
        }
    }

    /// Sets the effective user ID of the calling process.
    ///
    /// - Throws: `Kernel.Error` on failure (EPERM if not privileged).
    public static func setEffectiveID(
        _ uid: Kernel.User.ID
    ) throws(Kernel.Error) {
        guard seteuid(uid.rawValue) == 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "seteuid")
        }
    }
}
