@_spi(Syscall) import Kernel_Process_Primitives

extension ISO_9945.Kernel.Group.Database {
    /// A group database entry (from /etc/group or equivalent).
    public struct Entry: Sendable {
        /// The group name.
        public let name: String

        /// The group ID.
        public let gid: Kernel.Group.ID

        /// The group member names.
        public let members: [String]

        internal init(name: String, gid: Kernel.Group.ID, members: [String]) {
            self.name = name
            self.gid = gid
            self.members = members
        }
    }
}
