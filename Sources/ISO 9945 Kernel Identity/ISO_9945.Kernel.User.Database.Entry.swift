extension ISO_9945.Kernel.User.Database {

    public struct Entry: Sendable {

        public let name: String

        public let uid: ISO_9945.Kernel.User.ID

        public let gid: ISO_9945.Kernel.Group.ID

        public let home: String

        public let shell: String
    }
}
