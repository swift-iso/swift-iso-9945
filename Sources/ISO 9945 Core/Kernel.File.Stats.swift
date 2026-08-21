extension ISO_9945.Kernel.File {

    public struct Stats: Sendable, Equatable {

        public let size: ISO_9945.Kernel.File.Size

        public let type: Kind

        public let permissions: ISO_9945.Kernel.File.Permissions

        public let uid: ISO_9945.Kernel.User.ID

        public let gid: ISO_9945.Kernel.Group.ID

        public let inode: ISO_9945.Kernel.Inode

        public let device: ISO_9945.Kernel.Device

        public let linkCount: ISO_9945.Kernel.Link.Count

        public let accessTime: ISO_9945.Kernel.Time

        public let modificationTime: ISO_9945.Kernel.Time

        public let changeTime: ISO_9945.Kernel.Time

        @inlinable
        public init(
            size: ISO_9945.Kernel.File.Size,
            type: Kind,
            permissions: ISO_9945.Kernel.File.Permissions,
            uid: ISO_9945.Kernel.User.ID,
            gid: ISO_9945.Kernel.Group.ID,
            inode: ISO_9945.Kernel.Inode,
            device: ISO_9945.Kernel.Device,
            linkCount: ISO_9945.Kernel.Link.Count,
            accessTime: ISO_9945.Kernel.Time,
            modificationTime: ISO_9945.Kernel.Time,
            changeTime: ISO_9945.Kernel.Time
        ) {
            self.size = size
            self.type = type
            self.permissions = permissions
            self.uid = uid
            self.gid = gid
            self.inode = inode
            self.device = device
            self.linkCount = linkCount
            self.accessTime = accessTime
            self.modificationTime = modificationTime
            self.changeTime = changeTime
        }
    }
}
