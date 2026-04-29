@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Effective Group ID

extension ISO_9945.Kernel.Group {
    /// Effective group ID operations namespace.
    public enum Effective {}
}

extension ISO_9945.Kernel.Group.Effective {
    /// Gets the effective group ID of the calling process.
    public static func id() -> Kernel.Group.ID {
        Kernel.Group.ID(__unchecked: (), getegid())
    }

    /// Sets the effective group ID of the calling process.
    ///
    /// - Throws: `Error_Primitives.Error` on failure (EPERM if not privileged).
    public static func set(
        _ gid: Kernel.Group.ID
    ) throws(Error_Primitives.Error) {
        guard setegid(gid.rawValue) == 0 else {
            throw Error_Primitives.Error.current(operation: "setegid")
        }
    }
}
