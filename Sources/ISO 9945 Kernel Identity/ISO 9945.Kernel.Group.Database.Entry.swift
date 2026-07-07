extension ISO_9945.Kernel.Group.Database {
    /// A group database entry (from /etc/group or equivalent).
    public struct Entry: Sendable {
        /// The group name.
        public let name: String

        /// The group ID.
        public let gid: ISO_9945.Kernel.Group.ID

        /// The group member names.
        public let members: [String]

        internal init(name: String, gid: ISO_9945.Kernel.Group.ID, members: [String]) {
            self.name = name
            self.gid = gid
            self.members = members
        }
    }
}
