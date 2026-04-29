@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Real Group ID

extension ISO_9945.Kernel.Group {
    /// Real group ID operations namespace.
    public enum Real {}
}

extension ISO_9945.Kernel.Group.Real {
    /// Gets the real group ID of the calling process.
    public static func id() -> Kernel.Group.ID {
        Kernel.Group.ID(__unchecked: (), getgid())
    }

    /// Sets the real group ID of the calling process.
    ///
    /// - Throws: `Error_Primitives.Error` on failure (EPERM if not privileged).
    public static func set(
        _ gid: Kernel.Group.ID
    ) throws(Error_Primitives.Error) {
        guard setgid(gid.rawValue) == 0 else {
            throw Error_Primitives.Error.current(operation: "setgid")
        }
    }
}
