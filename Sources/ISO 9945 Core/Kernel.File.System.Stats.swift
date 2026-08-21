extension ISO_9945.Kernel.File.System {

    public struct Stats: Sendable, Equatable, Hashable {

        public let type: ISO_9945.Kernel.File.System.Kind

        public let blockSize: ISO_9945.Kernel.File.System.Block.Size

        public let blocks: ISO_9945.Kernel.File.System.Block.Count

        public let freeBlocks: ISO_9945.Kernel.File.System.Block.Count

        public let availableBlocks: ISO_9945.Kernel.File.System.Block.Count

        public let files: ISO_9945.Kernel.File.System.File.Count

        public let freeFiles: ISO_9945.Kernel.File.System.File.Count

        public let fsid: ISO_9945.Kernel.File.System.ID

        public let nameMax: ISO_9945.Kernel.File.System.Name.Length

        public let fsTypeName: Swift.String?

        public init(
            type: ISO_9945.Kernel.File.System.Kind,
            blockSize: ISO_9945.Kernel.File.System.Block.Size,
            blocks: ISO_9945.Kernel.File.System.Block.Count,
            freeBlocks: ISO_9945.Kernel.File.System.Block.Count,
            availableBlocks: ISO_9945.Kernel.File.System.Block.Count,
            files: ISO_9945.Kernel.File.System.File.Count,
            freeFiles: ISO_9945.Kernel.File.System.File.Count,
            fsid: ISO_9945.Kernel.File.System.ID,
            nameMax: ISO_9945.Kernel.File.System.Name.Length,
            fsTypeName: Swift.String? = nil
        ) {
            self.type = type
            self.blockSize = blockSize
            self.blocks = blocks
            self.freeBlocks = freeBlocks
            self.availableBlocks = availableBlocks
            self.files = files
            self.freeFiles = freeFiles
            self.fsid = fsid
            self.nameMax = nameMax
            self.fsTypeName = fsTypeName
        }
    }
}
