extension ISO_9945.Kernel.Group.Database {

    public struct Entry: Sendable {

        public let name: String

        public let gid: ISO_9945.Kernel.Group.ID

        public let members: [String]
    }
}
