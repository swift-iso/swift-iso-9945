
#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {
    /// Supplementary group operations namespace.
    public enum Supplementary {}
}

// MARK: - Query

extension ISO_9945.Kernel.Group.Supplementary {
    /// Gets the supplementary group IDs of the calling process.
    ///
    /// - Returns: Array of supplementary group IDs.
    /// - Throws: `Error_Primitives.Error` on failure.
    public static func get() throws(Error_Primitives.Error) -> [ISO_9945.Kernel.Group.ID] {
        let count = getgroups(0, nil)
        guard count >= 0 else {
            throw Error_Primitives.Error.current(operation: "getgroups")
        }

        guard count > 0 else { return [] }

        var gids = [gid_t](repeating: 0, count: Int(count))
        let result = unsafe gids.withUnsafeMutableBufferPointer { buf in
            unsafe getgroups(count, buf.baseAddress!)
        }

        guard result >= 0 else {
            throw Error_Primitives.Error.current(operation: "getgroups")
        }

        return gids.prefix(Int(result)).map { ISO_9945.Kernel.Group.ID(__unchecked: (), $0) }
    }
}
