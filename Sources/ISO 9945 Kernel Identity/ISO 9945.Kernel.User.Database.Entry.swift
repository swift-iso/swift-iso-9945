
extension ISO_9945.Kernel.User.Database {
    /// A user database entry (from /etc/passwd or equivalent).
    public struct Entry: Sendable {
        /// The user name.
        public let name: String

        /// The user ID.
        public let uid: ISO_9945.Kernel.User.ID

        /// The primary group ID.
        public let gid: ISO_9945.Kernel.Group.ID

        /// The user's home directory.
        public let home: String

        /// The user's login shell.
        public let shell: String

        internal init(name: String, uid: ISO_9945.Kernel.User.ID, gid: ISO_9945.Kernel.Group.ID, home: String, shell: String) {
            self.name = name
            self.uid = uid
            self.gid = gid
            self.home = home
            self.shell = shell
        }
    }
}
