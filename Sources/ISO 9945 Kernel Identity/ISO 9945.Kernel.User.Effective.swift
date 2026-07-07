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
    public static func id() -> ISO_9945.Kernel.User.ID {
        ISO_9945.Kernel.User.ID(_unchecked: geteuid())
    }

    /// Sets the effective user ID of the calling process.
    ///
    /// - Throws: `Error_Primitives.Error` on failure (EPERM if not privileged).
    public static func set(
        _ uid: ISO_9945.Kernel.User.ID
    ) throws(Error_Primitives.Error) {
        guard seteuid(uid.underlying) == 0 else {
            throw Error_Primitives.Error.current(operation: "seteuid")
        }
    }
}
