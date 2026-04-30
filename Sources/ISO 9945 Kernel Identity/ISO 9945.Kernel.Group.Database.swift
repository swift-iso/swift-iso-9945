
#if canImport(Darwin)
    internal import Darwin
#elseif canImport(Glibc)
    internal import Glibc
#elseif canImport(Musl)
    internal import Musl
#endif

extension ISO_9945.Kernel.Group {
    /// Group database operations namespace.
    public enum Database {}
}

// MARK: - Lookup

extension ISO_9945.Kernel.Group.Database {
    /// Looks up a group by name.
    ///
    /// - Parameter name: The group name to look up.
    /// - Returns: The group entry, or `nil` if not found.
    public static func find(name: String) -> Entry? {
        guard let gr = unsafe getgrnam(name) else { return nil }
        return unsafe entry(from: gr)
    }

    /// Looks up a group by group ID.
    ///
    /// - Parameter gid: The group ID to look up.
    /// - Returns: The group entry, or `nil` if not found.
    public static func find(gid: Kernel.Group.ID) -> Entry? {
        guard let gr = unsafe getgrgid(gid.rawValue) else { return nil }
        return unsafe entry(from: gr)
    }

    private static func entry(from gr: UnsafePointer<group>) -> Entry {
        var members: [String] = []
        if let memberList = unsafe gr.pointee.gr_mem {
            var i = 0
            while let member = unsafe memberList[i] {
                unsafe members.append(String(cString: member))
                i += 1
            }
        }

        return unsafe Entry(
            name: String(cString: gr.pointee.gr_name),
            gid: Kernel.Group.ID(__unchecked: (), gr.pointee.gr_gid),
            members: members
        )
    }
}
