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
    public static func id() -> ISO_9945.Kernel.Group.ID {
        ISO_9945.Kernel.Group.ID(_unchecked: getegid())
    }

    /// Sets the effective group ID of the calling process.
    ///
    /// - Throws: `Error_Primitives.Error` on failure (EPERM if not privileged).
    public static func set(
        _ gid: ISO_9945.Kernel.Group.ID
    ) throws(Error_Primitives.Error) {
        guard setegid(gid.underlying) == 0 else {
            throw Error_Primitives.Error.current(operation: "setegid")
        }
    }
}
