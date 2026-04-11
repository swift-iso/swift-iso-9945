@_spi(Syscall) import Kernel_Process_Primitives

#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

// MARK: - Group ID Query Operations

extension ISO_9945.Kernel.Group {
    /// Gets the real group ID of the calling process.
    public static func realID() -> Kernel.Group.ID {
        Kernel.Group.ID(__unchecked: (),getgid())
    }

    /// Gets the effective group ID of the calling process.
    public static func effectiveID() -> Kernel.Group.ID {
        Kernel.Group.ID(__unchecked: (),getegid())
    }

    /// Sets the real group ID of the calling process.
    ///
    /// - Throws: `Kernel.Error` on failure (EPERM if not privileged).
    public static func setRealID(
        _ gid: Kernel.Group.ID
    ) throws(Kernel.Error) {
        guard setgid(gid.rawValue) == 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "setgid")
        }
    }

    /// Sets the effective group ID of the calling process.
    ///
    /// - Throws: `Kernel.Error` on failure (EPERM if not privileged).
    public static func setEffectiveID(
        _ gid: Kernel.Group.ID
    ) throws(Kernel.Error) {
        guard setegid(gid.rawValue) == 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "setegid")
        }
    }

    /// Gets the supplementary group IDs of the calling process.
    ///
    /// - Returns: Array of supplementary group IDs.
    /// - Throws: `Kernel.Error` on failure.
    public static func supplementary() throws(Kernel.Error) -> [Kernel.Group.ID] {
        let count = getgroups(0, nil)
        guard count >= 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "getgroups")
        }

        guard count > 0 else { return [] }

        var gids = [gid_t](repeating: 0, count: Int(count))
        let result = unsafe gids.withUnsafeMutableBufferPointer { buf in
            unsafe getgroups(count, buf.baseAddress!)
        }

        guard result >= 0 else {
            throw ISO_9945.Kernel.Error.current(operation: "getgroups")
        }

        return gids.prefix(Int(result)).map { Kernel.Group.ID(__unchecked: (),$0) }
    }
}
